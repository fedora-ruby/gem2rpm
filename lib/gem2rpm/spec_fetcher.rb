require 'delegate'

module Gem2Rpm
  class SpecFetcher < SimpleDelegator
    # Find and fetch specs that match +dependency+.
    #
    # If +matching_platform+ is false, gems for all platforms are returned.
    def spec_for_dependency(dependency, matching_platform=true)
      super
    rescue
      find_matching(dependency, true, matching_platform)
    end
  end
end
