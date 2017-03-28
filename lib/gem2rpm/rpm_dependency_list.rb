require 'gem2rpm/rpm_dependency'

module Gem2Rpm
  class RpmDependencyList
    include Enumerable

    def initialize(dependencies)
      @items = dependencies.map { |r| RpmDependency.new(r) }
    end

    # Calls the given block once for each element in self, passing that
    # element as a parameter. Returns the array itself.
    # If no block is given, an Enumerator is returned.
    def each
      # Return Enumerator when called withoug block.
      return to_enum(__callee__) unless block_given?

      @items.each { |item| yield item }
    end

    # Returns string with all dependencies from the list converted into entries
    # suitable for RPM .spec file. Thise entries should include all necessary
    # macros depending on file categorization.
    def to_rpm
      entries.map(&:to_rpm).join("\n")
    end
  end
end
