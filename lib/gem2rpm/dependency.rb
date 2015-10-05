require 'delegate'
require 'gem2rpm/helpers'

module Gem2Rpm
  class Dependency < SimpleDelegator
    # What does this dependency require?
    def requirement
      r = begin
        super
      rescue
        version_requirements # For RubyGems < 1.3.6
      end

      Helpers.requirement_versions_to_rpm r
    end

    # Dependency type. Needs to be explicitly reimplemented.
    def type
      __getobj__.type
    end
  end
end
