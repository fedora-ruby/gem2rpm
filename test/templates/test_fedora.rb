require 'helper'

class TestFedora < Minitest::Test
  def template
    @template ||= begin
      fedora_rawhide_template = Dir.glob(File.join(File.dirname(__FILE__), '..', '..', 'templates', '*rawhide.spec.erb')).first
      Gem2Rpm::Template.new fedora_rawhide_template
    end
  end

  def setup
    @out = StringIO.new
    Gem2Rpm.convert(gem_path, template, @out, false)
    @out_string = @out.string
  end

  def test_url
    assert_match(/\sURL: /, @out_string)
  end

  def test_rubys_version_build_requirement
    assert_match(/\sBuildRequires: ruby-devel >= 1.8.6/, @out_string)
  end

  def test_ruby_is_not_required
    refute_match(/\sRequires: ruby >= 1.8.6/, @out_string)
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
    refute_match(/\sruby\(rubygems\)/, @out_string)
  end

  def test_nothing_is_required
    refute_match(/\sRequires:\s*rubygem\(\w*\).*$/, @out_string)
  end

  def test_provides_is_not_generated_anymore
    refute_match(/\sProvides:\s*rubygem\(%\{gem_name\}\)/, @out_string)
  end

  def test_file_list
    assert_match(/\s%dir %\{gem_instdir\}/, @out_string)
    assert_match(/\s%\{gem_libdir\}/, @out_string)
    assert_match(/\s%\{gem_instdir\}\/runtime/, @out_string)
    assert_match(/\s%\{gem_instdir\}\/Gemfile/, @out_string)
    assert_match(/\s%\{gem_instdir\}\/Rakefile/, @out_string)
    assert_match(/\s%\{gem_spec\}/, @out_string)
    assert_match(/\s%doc %\{gem_docdir\}/, @out_string)
    assert_match(/\s%doc %\{gem_instdir\}\/README/, @out_string)
    assert_match(/\s%exclude %\{gem_instdir\}\/\.travis\.yml/, @out_string)
  end

  def test_rawhide_does_not_provide_group_tag
    rawhide_templates = Gem2Rpm::Template.list.grep(/.*rawhide.*\.spec\.erb/)
    rawhide_templates.each do |t|
      out = StringIO.new
      t = File.join Gem2Rpm::Template.default_location, t
      Gem2Rpm.convert(gem_path, Gem2Rpm::Template.new(t), out, false)
      refute_match(/Group:/, out.string)
    end
  end
end
