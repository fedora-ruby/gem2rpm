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

  def test_omitting_development_requirements_from_spec
    # Only run this test if rubygems 1.2.0 or later.
    if Gem::Version.create(Gem::RubyGemsVersion) >= Gem::Version.create("1.2.0")
      out = StringIO.new

      gem_path = File.join(File.dirname(__FILE__), "artifacts", "test-1.0.0.gem") 
      Gem2Rpm::convert(gem_path, Gem2Rpm::TEMPLATE, out, false)

      assert_no_match(/\sRequires: rubygem\(test_development\)/, out.string)
    end
  end

  def test_omitting_url_from_rpm_spec
    out = StringIO.new

    gem_path = File.join(File.dirname(__FILE__), "artifacts", "test-1.0.0.gem") 
    Gem2Rpm::convert(gem_path, Gem2Rpm::TEMPLATE, out, false)

    assert_no_match(/\sURL: /, out.string)
  end

end
