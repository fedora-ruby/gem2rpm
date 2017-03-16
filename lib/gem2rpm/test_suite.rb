require 'gem2rpm/rpm_file_list'

module Gem2Rpm
  class TestSuite
    include Enumerable

    TestFramework = Struct.new :name, :command

    TEST_FRAMEWORKS = [
      TestFramework.new('cucumber', %|cucumber|),
      TestFramework.new('minitest', %|ruby -e 'Dir.glob "./test/**/*_test.rb", &method(:require)'|),
      TestFramework.new('rspec', %|rspec spec|),
      TestFramework.new('shindo', %|shindont|),
      TestFramework.new('test-unit', %|ruby -e 'Dir.glob "./test/**/*_test.rb", &method(:require)'|),
      TestFramework.new('bacon', %|bacon -a|),
    ]

    def initialize(spec)
      @items = detect_test_frameworks(spec)
    end

    def each
      # Return Enumerator when called withoug block.
      return to_enum(__callee__) unless block_given?

      @items.each { |item| yield item }
    end

    def detect_test_frameworks(spec)
      from_development_dependencies(spec)
      # TODO: Try to guess the test framework from spec.files. This could
      # improve the test execution command a bit, but might not be reliable.
    end

    def from_development_dependencies(spec)
      deps = spec.development_dependencies.map(&:name)
      TEST_FRAMEWORKS.select { |tf| deps.include?(tf.name) }.map(&:dup)
    end
  end
end
