require 'singleton'

module Gem2Rpm
  class Configuration
    include Singleton

    # The defaults should mostly work
    DEFAULT_MACROS = {
      :instdir => '%{gem_instdir}',
      :doc => '%doc',
      :license => '%license',
      :ignore => '%exclude'
    }

    DEFAULT_RULES = {
      :doc => [/\/?CHANGELOG.*/i, /\/?CONTRIBUTING.*/i, /\/?CONTRIBUTORS.*/i,
               /\/?AUTHORS.*/i,/\/?README.*/i, /\/?History.*/i, /\/?Release.*/i,
               /\/?doc(\/.*)?/],
      :license => [/\/?MIT/, /\/?GPLv[0-9]+/, /\/?.*LICEN(C|S)E/, /\/?COPYING/],
      :ignore => ['.gemtest', '.gitignore', '.travis.yml', '.yardopts', '.rvmrc'],
      # Other files including test files that are not required for
      # runtime and therefore currently included in -doc
      :misc => [/.*.gemspec/, /Gemfile.*/, 'Rakefile', 'rakefile.rb', 'Vagrantfile',
                /spec.*/, /rspec.*/, /test(s|)/, /examples.*/]
    }

    # Hash with macros for files categories
    def macros
      @_macros ||= DEFAULT_MACROS
    end

    # Hash with rules for file categorization
    def rules
      @_rules ||= DEFAULT_RULES
    end

    def macro_for(category)
      macros[category] ||= ''
    end

    def rule_for(category)
      rules[category] ||= ''
    end

  end
end
