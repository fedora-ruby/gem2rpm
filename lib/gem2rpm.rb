require 'erb'
require 'socket'
require 'rubygems'
require 'gem2rpm/distro'
require 'gem2rpm/specification'
require 'gem2rpm/spec_fetcher'
require 'gem2rpm/package'

module Gem2Rpm
  Gem2Rpm::VERSION = "0.8.4"

  def self.find_download_url(name, version)
    # RubyGems < 1.0.0 uses RemoteInstaller
    if Gem::Version.create(Gem::RubyGemsVersion) >= Gem::Version.create("1.0.0")
      fetcher = Gem2Rpm::SpecFetcher.new(Gem::SpecFetcher.new)
      dep = Gem::Dependency.new(name, "=#{version}")
      dummy, download_path = fetcher.spec_for_dependency(dep).first
    else
      require 'rubygems/remote_installer'
      installer = Gem::RemoteInstaller.new
      dummy, download_path = installer.find_gem_to_install(name, "=#{version}")
    end
    download_path += "gems/" if download_path.to_s != ""
    return download_path
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
