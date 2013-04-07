require 'erb'
require 'socket'
require 'rubygems'
require 'gem2rpm/distro'
require 'gem2rpm/specification'

# Adapt to the differences between rubygems < 1.0.0 and after
# Once we can be reasonably certain that everybody has version >= 1.0.0
# all this logic should be killed
GEM_VERSION = Gem::Version.create(Gem::RubyGemsVersion)
HAS_REMOTE_INSTALLER = GEM_VERSION < Gem::Version.create("1.0.0")

# Adapt to changes that RubyGems 2.0.0 introduces
RUBYGEMS_2 = GEM_VERSION >= Gem::Version.create("2.0.0")

if HAS_REMOTE_INSTALLER
  require 'rubygems/remote_installer'
end

require 'gem2rpm/package'

module Gem2Rpm
  Gem2Rpm::VERSION = "0.8.4"

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

      if RUBYGEMS_2
        dummy, download_path = fetcher.spec_for_dependency(dep, false).first
      else
        dummy, download_path = fetcher.find_matching(dep, false, false).first
      end

      download_path += "gems/" if download_path.to_s != ""
      return download_path
    end
  end

  def Gem2Rpm.convert(fname, template=TEMPLATE, out=$stdout,
                      nongem=true, local=false, doc_subpackage = true)
    # For the template
    gem_path = File::basename(fname)

    # Keep format for backwards compatibility of custom templates for RubyGems < 2
    package = format = Gem2Rpm::Package.new(fname)

    spec = Gem2Rpm::Specification.new(package.spec)
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
    template = ERB.new(template, 0, '-')
    out.puts template.result(binding)
  rescue Gem::Exception => e
    puts e
  end

  # Returns the email address of the packager (i.e., the person running
  # gem2spec).  Taken from RPM macros if present, constructed from system
  # username and hostname otherwise.
  def Gem2Rpm.packager()
    packager = `rpmdev-packager`.chomp rescue ''

    if packager.empty?
      packager = `rpm --eval '%{packager}'`.chomp rescue ''
    end

    if packager.empty? or packager == '%{packager}'
      passwd_entry = Etc::getpwnam(Etc::getlogin)
      packager = "#{(passwd_entry && passwd_entry.gecos) || Etc::getlogin } <#{Etc::getlogin}@#{Socket::gethostname}>"
    end

    packager
  end

  def Gem2Rpm.template_dir
    File.join(File.dirname(__FILE__), '..', 'templates')
  end

  TEMPLATE = File.read File.join(template_dir, "#{Distro.nature.to_s}.spec.erb")
end

# Local Variables:
# ruby-indent-level: 2
# End:
