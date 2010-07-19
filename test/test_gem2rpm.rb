$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'test/unit'
require 'rubygems'
require 'rubygems/version'
require 'gem2rpm'

class TestVersionConversion < Test::Unit::TestCase

  def test_simple_conversion
    r = Gem::Requirement.new("> 1.0")
    assert_equal(["> 1.0"] ,r.to_rpm)
  end

  def test_match_any_version_conversion
    r = Gem::Requirement.new("> 0.0.0")
    assert_equal([""] ,r.to_rpm)
  end

  def test_match_ranged_version_conversion
    r = Gem::Requirement.new(["> 1.2", "< 2.0"])
    assert_equal(["> 1.2", "< 2.0"] ,r.to_rpm)
  end

  def test_first_level_pessimistic_version_constraint
    r = Gem::Requirement.new(["~> 1.2"])
    assert_equal(["=> 1.2", "< 2"] ,r.to_rpm)
  end

  def test_second_level_pessimistic_version_constraint
    r = Gem::Requirement.new(["~> 1.2.3"])
    assert_equal(["=> 1.2.3", "< 1.3"] ,r.to_rpm)
  end

  def test_pessimistic_version_constraint_with_trailing_text
    # Trailing text was only allowed starting around rubygems 1.3.2.
    gem_version = Gem::Version.create(Gem::RubyGemsVersion)
    if gem_version >= Gem::Version.create("1.3.2")
      r = Gem::Requirement.new(["~> 1.2.3.beta.8"])
      assert_equal(["=> 1.2.3.beta.8", "< 1.3"] ,r.to_rpm)
    end
  end

end
