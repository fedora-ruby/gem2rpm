require 'delegate'
require 'gem2rpm/helpers'

module Gem2Rpm
  class Dependency < SimpleDelegator
    # What does this dependency require?
    def requirement
      Helpers.requirement_versions_to_rpm super
    end

    # Dependency type. Needs to be explicitly reimplemented.
    def type
      __getobj__.type
    end
  end
end
