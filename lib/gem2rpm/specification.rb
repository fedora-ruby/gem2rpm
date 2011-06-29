require 'delegate'
require 'gem2rpm/dependency'
require 'gem2rpm/helpers'

module Gem2Rpm
  class Specification < SimpleDelegator
    # A long description of gem wrapped to 78 characters.
    def description
      Helpers::word_wrap(super.to_s.chomp, 78) + "\n"
    end

    # A list of Gem::Dependency objects this gem depends on (includes every
    # runtime or development dependency).
    def dependencies
      super.map {|d| Gem2Rpm::Dependency.new d}
    end

    # List of dependencies that are used for development.
    def development_dependencies
      super.map {|d| Gem2Rpm::Dependency.new d}
    end

    # List of dependencies that will automatically be activated at runtime.
    def runtime_dependencies
      super.map {|d| Gem2Rpm::Dependency.new d}
    end

    # The version of Ruby required by the gem. Returns array with
    # empty string if the method is not provided by RubyGems yet.
    def required_ruby_version
      @required_ruby_version ||= begin
        Helpers.requirement_versions_to_rpm(super)
      rescue
        ['']
      end
    end

    # The RubyGems version required by gem. For RubyGems < 0.9.5 returns only
    # array with empty string. However, this should happen only in rare cases.
    def required_rubygems_version
      @required_rubygems_version ||= begin
        Helpers::requirement_versions_to_rpm(super)
      rescue
        ['']
      end
    end
  end
end
