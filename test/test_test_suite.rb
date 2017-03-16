require 'helper'
require 'gem2rpm/test_suite'

class TestTestSuite < Minitest::Test
  def setup
    @gemspec = Gem::Specification.new

    @gemspec.add_development_dependency "foo"
    @gemspec.add_development_dependency "bar"

    @spec = Gem2Rpm::Specification.new @gemspec
  end

  def teardown
    @spec = nil
    @gemspec = nil
  end

  def test_no_test_suite_dependency
    test_suites = Gem2Rpm::TestSuite.new(@spec)
    assert_equal 0, test_suites.entries.size
  end

  Gem2Rpm::TestSuite::TEST_FRAMEWORKS.each do |tf|
    define_method :"test_#{tf.name}_dependency" do
      @gemspec.add_development_dependency tf.name
      test_suites = Gem2Rpm::TestSuite.new(@spec)

      assert_equal 1, test_suites.entries.size

      test_suite = test_suites.first

      assert_equal tf, test_suite
      refute_same tf, test_suite
    end
  end
end
