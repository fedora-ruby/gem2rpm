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
      # Return Enumerator when called without block.
      return to_enum(__callee__) unless block_given?

      @items.each { |item| yield item }
    end

    # Returns a new array containing the items in self for which the given
    # block is not true. The ordering of non-rejected elements is maintained.
    # If no block is given, an Enumerator is returned instead.
    def reject
      # Return Enumerator when called without block.
      return to_enum(__callee__) unless block_given?

      self.class.new(@items.reject { |item| yield item })
    end

    # Convert to rubygem() virtual provide dependencies.
    def virtualize
      dep_list = self.map(&:virtualize)

      self.class.new dep_list
    end

    # Output dependencies with RPM requires tag.
    def with_requires
      dep_list = self.map(&:with_requires)

      self.class.new dep_list
    end

    # Comment out the dependency.
    def comment_out
      dep_list = self.map(&:comment_out)

      self.class.new dep_list
    end

    # Represent as boolean RPM dependency.
    def booleanize
      dep_list = self.map(&:booleanize)

      self.class.new dep_list
    end

    # Returns string with all dependencies from the list converted into entries
    # suitable for RPM .spec file. Thise entries should include all necessary
    # macros depending on file categorization.
    def to_rpm
      s = entries.map(&:to_rpm).join("\n")
      s += "\n" unless s.empty?
    end
  end
end
