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

end
