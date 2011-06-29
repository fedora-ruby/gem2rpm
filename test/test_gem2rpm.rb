require 'helper'

class TestGem2Rpm < Test::Unit::TestCase

  def test_omitting_development_requirements_from_spec
    # Only run this test if rubygems 1.2.0 or later.
    if Gem::Version.create(Gem::RubyGemsVersion) >= Gem::Version.create("1.2.0")
      out = StringIO.new

      gem_path = File.join(File.dirname(__FILE__), "artifacts", "testing_gem", "testing_gem-1.0.0.gem") 
      Gem2Rpm::convert(gem_path, Gem2Rpm::TEMPLATE, out, false)

      assert_no_match(/\sRequires: rubygem\(test_development\)/, out.string)
    end
  end

  def test_omitting_url_from_rpm_spec
    out = StringIO.new

    gem_path = File.join(File.dirname(__FILE__), "artifacts", "testing_gem", "testing_gem-1.0.0.gem") 

    Gem2Rpm::convert(gem_path, Gem2Rpm::TEMPLATE, out, false)

    assert_no_match(/\sURL: /, out.string)
  end

  def test_rubygems_version_requirement
    out = StringIO.new

    gem_path = File.join(File.dirname(__FILE__), "artifacts", "testing_gem", "testing_gem-1.0.0.gem") 

    Gem2Rpm::convert(gem_path, Gem2Rpm::TEMPLATE, out, false)

    assert_match(/\sRequires: ruby\(rubygems\) >= 1.3.6/, out.string)
  end

  def test_rubys_version_requirement
    out = StringIO.new

    gem_path = File.join(File.dirname(__FILE__), "artifacts", "testing_gem", "testing_gem-1.0.0.gem") 

    Gem2Rpm::convert(gem_path, Gem2Rpm::TEMPLATE, out, false)

    assert_match(/\sRequires: ruby >= 1.8.6/, out.string)
    assert_match(/\sBuildRequires: ruby >= 1.8.6/, out.string)
  end

end
