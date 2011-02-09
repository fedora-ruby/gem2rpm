require 'erb'
require 'socket'
require 'rubygems/format'
require 'gem2rpm/distro'

# Adapt to the differences between rubygems < 1.0.0 and after
# Once we can be reasonably certain that everybody has version >= 1.0.0
# all this logic should be killed
GEM_VERSION = Gem::Version.create(Gem::RubyGemsVersion)
HAS_REMOTE_INSTALLER = GEM_VERSION < Gem::Version.create("1.0.0")

if HAS_REMOTE_INSTALLER
  require 'rubygems/remote_installer'
end

# Extend String with a word_wrap method, which we use in the ERB template
# below.  Taken with modification from the word_wrap method in ActionPack.
# Text::Format does the smae thing better.
class String
  def word_wrap(line_width = 80)
    gsub(/\n/, "\n\n").gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip
  end
end

module Gem
  class Requirement
    def rpm_version_transform(version)
      if version == "> 0.0.0"
        version = ""
      elsif version =~ /^~> (.+)$/
        next_version = Gem::Version.create($1).bump.to_s

        version = ["=> #$1", "< #{next_version}"]
      end
      version
    end

    def to_rpm
      result = as_list
      return result.map { |version| rpm_version_transform(version) }.flatten
    end

  end
end

module Gem2Rpm
  Gem2Rpm::VERSION = "0.6.0"

  if HAS_REMOTE_INSTALLER
    def self.find_download_url(name, version)
      installer = Gem::RemoteInstaller.new
      dummy, download_path = installer.find_gem_to_install(name, "=#{version}")
      download_path += "/gems/" if download_path.to_s != ""
      return download_path
    end
  else
    def self.find_download_url(name, version)
      dep = Gem::Dependency.new(name, "=#{version}")
      fetcher = Gem::SpecFetcher.fetcher
      dummy, download_path = fetcher.find_matching(dep, false, false).first
      download_path += "gems/" if download_path.to_s != ""
      return download_path
    end
  end

  def Gem2Rpm.convert(fname, template=TEMPLATE, out=$stdout,
                      nongem=true, local=false)
    format = Gem::Format.from_file_by_path(fname)
    spec = format.spec
    spec.description ||= spec.summary
    download_path = ""
    unless local
      begin
        download_path = find_download_url(spec.name, spec.version)
      rescue Gem::Exception => e
        $stderr.puts "Warning: Could not retrieve full URL for #{spec.name}\nWarning: Edit the specfile and enter the full download URL as 'Source0' manually"
        $stderr.puts "#{e.inspect}"
      end
    end
    template = ERB.new(template, 0, '<>')
    out.puts template.result(binding)
  end

  # Returns the email address of the packager (i.e., the person running
  # gem2spec).  Taken from RPM macros if present, constructed from system
  # username and hostname otherwise.
  def Gem2Rpm.packager()
    packager = `rpmdev-packager`.chomp

    if packager.empty?
      packager = `rpm --eval '%{packager}'`.chomp
    end

    if packager.empty? or packager == '%{packager}'
      packager = "#{Etc::getpwnam(Etc::getlogin).gecos} <#{Etc::getlogin}@#{Socket::gethostname}>"
    end

    packager
  end

  TEMPLATE = File.read File.join(File.dirname(__FILE__), '..', 'templates', "#{Distro.nature.to_s}.spec.erb")
end

# Local Variables:
# ruby-indent-level: 2
# End:
