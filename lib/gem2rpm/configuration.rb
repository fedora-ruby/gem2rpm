require 'optparse'
require 'singleton'

module Gem2Rpm
  class Configuration
    include Singleton

    class InvalidOption < Exception; end

    CURRENT_DIR = Dir.pwd

    DEFAULT_OPTIONS = {
      :print_template_file => nil,
      :template_file => nil,
      :templates => false,
      :version => false,
      :output_file => nil,
      :local => false,
      :srpm => false,
      :deps => false,
      :nongem => false,
      :doc_subpackage => true,
      :fetch => false,
      :directory => CURRENT_DIR,
    }.freeze

    # The defaults should mostly work
    DEFAULT_MACROS = {
      :instdir => '%{gem_instdir}',
      :libdir => '%{gem_libdir}',
      :doc => '%doc',
      :license => '%license',
      :ignore => '%exclude'
    }.freeze

    DEFAULT_RULES = {
      :doc => [
        /\/?CHANGELOG.*/i,
        /\/?CHANGES.*/i,
        /\/?CONTRIBUTING.*/i,
        /\/?CONTRIBUTORS.*/i,
        /\/?AUTHORS.*/i,
        /\/?README.*/i,
        /\/?History.*/i,
        /\/?Release.*/i,
        /\/?SECURITY.*/i,
        /\/?doc(\/.*)?/,
        'Appraisals',
        'NEWS',
        'TODO',
      ],
      :license => [
        /\/?MIT/,
        /\/?GPLv[0-9]+/,
        /\/?.*LICEN(C|S)E/i,
        /\/?COPYING/,
      ],
      :ignore => [
        '.gemtest',
        '.gitignore',
        '.github',
        '.travis.yml',
        '.hound.yml',
        '.yardopts',
        '.rspec',
        '.rvmrc',
        '.rubocop.yml',
        '.rubocop_todo.yml',
        '.ruby-version',
        /^\..*rc$/i,
        'appveyor.yml',
        'coveralls.yml',
        'Guardfile',
      ],
      :test => [
        '.rspec',
        'cucumber.yml',
        /^features.*/,
        /^r?spec.*/,
        /^tests?/,
      ],
      # Other files including test files that are not required for
      # runtime and therefore currently included in -doc
      :misc => [
        /Gemfile.*/,
        'Rakefile',
        'rakefile.rb',
        'Vagrantfile',
        /^examples.*/,
        /\/?.*\.gemspec$/,
      ]
    }.freeze

    def initialize
      @options = nil
      @parser = nil
    end

    # Set the configuration back to default values
    def reset
      @_macros = nil
      @_rules = nil
      self
    end

    # Hash with macros for files categories
    def macros
      @_macros ||= DEFAULT_MACROS.dup
    end

    # Hash with rules for file categorization
    def rules
      @_rules ||= DEFAULT_RULES.dup
    end

    def macro_for(category)
      macros[category] ||= ''
    end

    def rule_for(category)
      rules[category] ||= ''
    end

    # Get options.
    def options
      handle_options unless @options
      @options
    end

    private

    # Handles list of given options. Use ARGV by default.
    def handle_options(args = ARGV)
      @options = Marshal.load Marshal.dump DEFAULT_OPTIONS # deep copy
      parser.parse!(args)
      @options[:args] = args
    # TODO: Refactor, this is probably not the best palce.
    rescue OptionParser::InvalidOption => e
      message = "#{e}\n\n#{parser}\n"
      fail(InvalidOption, message)
    end

    # Creates an option parser.
    def create_option_parser
      @parser = OptionParser.new
      setup_parser_options
    end

    # Get parser instance.
    def parser
      create_option_parser unless @parser
      @parser
    end

    def setup_parser_options
      parser.banner = "Usage: #{$PROGRAM_NAME} [OPTIONS] GEM"

      parser.separator('  Convert Ruby gems to source RPMs and specfiles.')
      parser.separator('  Uses a template to generate the RPM specfile')
      parser.separator('  from the gem specification.')

      parser.separator('')

      parser.separator('  Options:')

      parser.on('-T', '--current-template', 'Print the current template') do
        options[:print_template_file] = true
      end

      parser.on('-t', '--template TEMPLATE', 'Use TEMPLATE for the specfile') do |val|
        options[:template_file] = val
      end

      parser.on('--templates', 'List all available templates') do
        options[:templates] = true
      end

      parser.on('-v', '--version', 'Print gem2rpm\'s version and exit') do
        options[:version] = true
      end

      parser.on('-o', '--output FILE', 'Send the specfile to FILE') do |val|
        options[:output_file] = val
      end

      parser.on('-s', '--srpm', 'Create a source RPM') do
        options[:srpm] = true
      end

      parser.on('-l', '--local', "Do not retrieve Gem information over
              #{' ' * 22} the network. Use on disconnected machines") do
        options[:local] = true
      end

      parser.on('-d', '--dependencies', 'Print the dependencies of the gem') do
        options[:deps] = true
      end

      parser.on('-n', '--nongem', 'Generate a subpackage for non-gem use') do
        options[:nongem] = true
      end

      parser.on('--no-doc', 'Disable document subpackage') do
        options[:doc_subpackage] = false
      end

      parser.on('--fetch', 'Fetch the gem from rubygems.org') do
        options[:fetch] = true
      end

      parser.on('-C', '--directory DIR', 'Change to directory DIR') do |val|
        options[:directory] = val
      end

      parser.separator('')

      parser.separator('  Arguments:')
      parser.separator('    GEM            The path to the locally stored gem package file or the name')
      parser.separator('                   of the gem when using --fetch.')

      parser.separator('')
    end
  end
end
