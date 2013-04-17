require 'delegate'

module Gem2Rpm
  class SpecFetcher < SimpleDelegator
    # Find and fetch specs that match +dependency+.
    def spec_for_dependency(dependency, matching_platform=true)
      super
    rescue
      # For RubyGems < 2
      find_matching(dependency, false, matching_platform)
    end
  end
end