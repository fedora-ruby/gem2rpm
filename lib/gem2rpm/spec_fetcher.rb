require 'delegate'
require 'ostruct'

module Gem2Rpm
  class SpecFetcher < SimpleDelegator
    # Find and fetch specs that match +dependency+.
    #
    # If +matching_platform+ is false, gems for all platforms are returned.
    def spec_for_dependency(dependency, matching_platform=true)
      super
    rescue
      errors = []

      begin
        spec, source = find_matching(dependency, true, matching_platform).first
      rescue Gem::Exception => e
        errors << OpenStruct.new(:error => e)
      end

      source = OpenStruct.new(:uri => source)
      [[[spec, source]], errors]
    end
  end
end
