require 'erb'
require 'socket'
require 'gem2rpm/context'
require 'gem2rpm/distro'
require 'gem2rpm/gem/format'
require 'gem2rpm/gem/package'
require 'gem2rpm/gem/spec_fetcher'
require 'gem2rpm/gem/specification'
require 'gem2rpm/rpm_dependency_list'
require 'gem2rpm/rpm_file_list'
require 'gem2rpm/template_helpers'
require 'gem2rpm/template'
require 'gem2rpm/test_suite'

module Gem2Rpm
  Gem2Rpm::VERSION = "1.0.2".freeze

  class Exception < RuntimeError; end
  class DownloadUrlError < Exception; end

  OPEN_MODE = # :nodoc:
    if Object.const_defined? :Encoding
      'r:UTF-8'
    else
      'r'
    end

  def self.show_message(message, obj = nil, out = $stderr)
    out.puts("#{message}\n\n")
    out.puts obj if obj
  end

  def self.show_templates(out = $stdout)
    out.puts "Available templates in #{Gem2Rpm::Template.default_location}:\n\n"
    template_list = Gem2Rpm::Template.list.map do |t|
      t = t.gsub(/(.*)\.spec.erb/, '\\1')
      t.gsub(/^/, t == Distro.nature ? '* ' : '  ')
    end.join("\n")
    out.puts template_list
  end

  def self.show_version(out = $stdout)
    out.puts Gem2Rpm::VERSION
  end

  def self.find_download_url(name, version)
    dep = Gem::Dependency.new(name, "=#{version}")
    fetcher = Gem2Rpm::SpecFetcher.new(Gem::SpecFetcher.fetcher)

    spec_and_source, errors = fetcher.spec_for_dependency(dep, false)

    fail DownloadUrlError, errors.first.error.message unless errors.empty?

    _spec, source = spec_and_source.first

    if source && source.uri
      download_path = source.uri.to_s
      download_path += "gems/"
    end

    download_path
  end

  def self.convert(fname, template, out = $stdout, nongem = true, local = false,
                      doc_subpackage = true)
    context = Gem2Rpm::Context.new(fname, nongem, local, doc_subpackage)

    # Check if keyword arguments are used. The condition could let go as soon
    # as only Ruby 2.6+ is supported.
    kwargs = !(ERB.new("").method(:initialize).parameters & [[:key, :trim_mode]]).empty?
    erb = if kwargs
            ERB.new(template.read, trim_mode: '-')
          else
            ERB.new(template.read, 0, '-')
          end
    out.puts erb.result(context.instance_eval { binding })
  rescue Gem::Exception => e
    puts e
  end

  # Print gem dependencies to the specified output ($stdout by default).
  def self.print_dependencies(gemfile, out = $stdout)
    dl = RpmDependencyList.new(Gem2Rpm::Package.new(gemfile).spec.dependencies)
    out.puts dl.virtualize.to_rpm
  end

  # Returns the email address of the packager (i.e., the person running
  # gem2spec).  Taken from RPM macros if present, constructed from system
  # username and hostname otherwise.
  def self.packager
    packager = `rpmdev-packager 2> /dev/null`.chomp rescue ''

    if packager.empty?
      packager = `rpm --eval '%{packager}' 2> /dev/null`.chomp rescue ''
    end

    if packager.empty? || (packager == '%{packager}')
      passwd_entry = Etc.getpwnam(Etc.getlogin)
      packager = "#{(passwd_entry && passwd_entry.gecos) || Etc.getlogin} <#{Etc.getlogin}@#{Socket.gethostname}>"
    end

    packager
  end

  def self.rubygem_template
    Template.new(File.join(Template.default_location, "#{Distro.nature}.spec.erb"))
  end

  def self.vagrant_plugin_template
    file = File.join(Template.default_location, "#{Distro.nature}-vagrant-plugin.spec.erb")
    Template.new(file)
  end
end

# Local Variables:
# ruby-indent-level: 2
# End:
