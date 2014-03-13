require 'helper'

class TestFedora < Test::Unit::TestCase

  def template
    @template ||= begin
      fedora_rawhide_template = Dir.glob(File.join(File.dirname(__FILE__), '..', '..', 'templates', '*rawhide*')).first
      File.read fedora_rawhide_template
    end
  end

  def setup
    @out = StringIO.new

    Gem2Rpm::convert(gem_path, template, @out, false)

    @out_string = @out.string
  end

  def test_omitting_url_from_rpm_spec
    assert_no_match(/\sURL: /, @out_string)
  end

  def test_rubys_version_build_requirement
    assert_match(/\sBuildRequires: ruby-devel >= 1.8.6/, @out_string)
  end

  def test_ruby_is_not_required
    assert_no_match(/\sRequires: ruby >= 1.8.6/, @out_string)
  end

  def test_description_end_with_dot
    assert_match(/%description\n.*\.\n\n/, @out_string)
    assert_match(/%description doc\n.*\.\n\n/, @out_string)
  end

  def test_exclude_extension_directory
    assert_match(/rm -rf %\{buildroot\}%\{gem_instdir\}\/ext\//, @out_string)
  end

  def test_build_requires
    assert_match(/^# BuildRequires: rubygem\(test_development\) >= 1\.0\.0$/, @out_string)
  end

  def test_rubygems_is_not_required
    assert_no_match(/\sruby\(rubygems\)/, @out_string)
  end

  def test_nothing_is_required
    assert_no_match(/\sRequires:\s*rubygem\(\w*\).*$/, @out_string)
  end

  def test_provides_is_not_generated_anymore
    assert_no_match(/\sProvides:\s*rubygem\(%\{gem_name\}\)/, @out_string)
  end

end
