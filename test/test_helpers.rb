require 'helper'
require 'gem2rpm/helpers'

class TestHelpers < Test::Unit::TestCase
  def test_simple_conversion
    r = Gem::Requirement.new("> 1.0")
    assert_equal(["> 1.0"], Gem2Rpm::Helpers.requirement_versions_to_rpm(r))
  end

  def test_match_any_version_conversion
    r = Gem::Requirement.default
    assert_equal([""], Gem2Rpm::Helpers.requirement_versions_to_rpm(r))
  end

  def test_match_ranged_version_conversion
    r = Gem::Requirement.new(["> 1.2", "< 2.0"])
    assert_equal(["> 1.2", "< 2.0"], Gem2Rpm::Helpers.requirement_versions_to_rpm(r))
  end

  def test_first_level_pessimistic_version_constraint
    r = Gem::Requirement.new(["~> 1.2"])
    assert_equal(["=> 1.2", "< 2"], Gem2Rpm::Helpers.requirement_versions_to_rpm(r))
  end

  def test_second_level_pessimistic_version_constraint
    r = Gem::Requirement.new(["~> 1.2.3"])
    assert_equal(["=> 1.2.3", "< 1.3"], Gem2Rpm::Helpers.requirement_versions_to_rpm(r))
  end

  def test_pessimistic_version_constraint_with_trailing_text
    # Trailing text was only allowed starting around rubygems 1.3.2.
    gem_version = Gem::Version.create(Gem::RubyGemsVersion)
    if gem_version >= Gem::Version.create("1.3.2")
      r = Gem::Requirement.new(["~> 1.2.3.beta.8"])
      assert_equal(["=> 1.2.3.beta.8", "< 1.3"], Gem2Rpm::Helpers.requirement_versions_to_rpm(r))
    end
  end

  def test_second_level_pessimistic_version_constraint_with_two_digit_version
    r = Gem::Requirement.new(["~> 1.12.3"])
    assert_equal(["=> 1.12.3", "< 1.13"], Gem2Rpm::Helpers.requirement_versions_to_rpm(r))
  end

  def test_first_level_not_equal_version_constraint
    r = Gem::Requirement.new(["!= 1.2"])
    assert_equal(["< 1.2", "> 1.2"], Gem2Rpm::Helpers.requirement_versions_to_rpm(r))
  end

  def test_second_level_not_equal_version_constraint
    r = Gem::Requirement.new(["!= 1.2.3"])
    assert_equal(["< 1.2.3", "> 1.2.3"], Gem2Rpm::Helpers.requirement_versions_to_rpm(r))
  end
end
