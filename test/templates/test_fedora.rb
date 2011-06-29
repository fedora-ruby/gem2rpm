require 'helper'

class TestFedora < Test::Unit::TestCase

  def template
    @template ||= File.read File.join(File.dirname(__FILE__), '..', '..', 'templates', 'fedora.spec.erb')
  end

  def test_omitting_url_from_rpm_spec
    out = StringIO.new

    Gem2Rpm::convert(gem_path, template, out, false)

    assert_no_match(/\sURL: /, out.string)
  end

  def test_rubygems_version_requirement
    out = StringIO.new

    Gem2Rpm::convert(gem_path, template, out, false)

    assert_match(/\sRequires: ruby\(rubygems\) >= 1.3.6/, out.string)
  end

  def test_rubys_version_requirement
    out = StringIO.new

    Gem2Rpm::convert(gem_path, template, out, false)

    assert_match(/\sRequires: ruby >= 1.8.6/, out.string)
    assert_match(/\sBuildRequires: ruby >= 1.8.6/, out.string)
  end

end
