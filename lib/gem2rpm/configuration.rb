require 'singleton'

module Gem2Rpm
  class Configuration
    include Singleton

    # The defaults should mostly work
    DEFAULT_MACROS = {
      :instdir => '%{gem_instdir}',
      :libdir => '%{gem_libdir}',
      :doc => '%doc',
      :license => '%license',
      :ignore => '%exclude'
    }

    DEFAULT_RULES = {
      :doc => [/\/?CHANGELOG.*/i, /\/?CONTRIBUTING.*/i, /\/?CONTRIBUTORS.*/i,
               /\/?AUTHORS.*/i, /\/?README.*/i, /\/?History.*/i, /\/?Release.*/i,
               /\/?doc(\/.*)?/, 'NEWS'],
      :license => [/\/?MIT/, /\/?GPLv[0-9]+/, /\/?.*LICEN(C|S)E/, /\/?COPYING/],
      :ignore => ['.gemtest', '.gitignore', '.travis.yml', '.yardopts', '.rvmrc',
                  '.rubocop.yml', /^\..*rc$/i],
      # Other files including test files that are not required for
      # runtime and therefore currently included in -doc
      :misc => [/.*.gemspec/, /Gemfile.*/, 'Rakefile', 'rakefile.rb', 'Vagrantfile',
                /^spec.*/, /^rspec.*/, /^test(s|)/, /^examples.*/]
    }

    # Set the configuration back to default
    def to_default
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

  end
end
