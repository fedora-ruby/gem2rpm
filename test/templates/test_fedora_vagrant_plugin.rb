require 'helper'

class TestFedoraVagrantPlugin < Minitest::Test

  def template
    @template ||= begin
      t = Dir.glob(File.join(File.dirname(__FILE__), '..', '..', 'templates', '*rawhide-vagrant-plugin.spec.erb')).first
      Gem2Rpm::Template.new t
    end
  end

  def setup
    @out = StringIO.new
    Gem2Rpm::convert(vagrant_plugin_path, template, @out, false)
    @out_string = @out.string
  end

  def test_omitting_url_from_rpm_spec
    refute_match(/\sURL: /, @out_string)
  end

  def test_ruby_is_not_required
    refute_match(/\sRequires: ruby >= 1.8.6/, @out_string)
  end

  def test_description_end_with_dot
    assert_match(/%description\n.*\.\n\n/, @out_string)
    assert_match(/%description doc\n.*\.\n\n/, @out_string)
  end

  def test_requires
    assert_match(/\sRequires\(posttrans\): vagrant/, @out_string)
    assert_match(/\sRequires\(preun\): vagrant/, @out_string)
    assert_match(/\sRequires: vagrant/, @out_string)
  end

  def test_build_requires
    assert_match(/^BuildRequires: vagrant/, @out_string)
    assert_match(/^BuildRequires: rubygems-devel/, @out_string)
    assert_match(/^BuildRequires: ruby/, @out_string)
  end

  def test_rubygems_is_not_required
    refute_match(/\sruby\(rubygems\)/, @out_string)
  end

  def test_provides
    assert_match(/\sProvides: vagrant\(%\{vagrant_plugin_name\}\) = %\{version\}/, @out_string)
  end

  def test_transactions
    assert_match(/\s%posttrans\n%vagrant_plugin_register %\{vagrant_plugin_name\}/, @out_string)
    assert_match(/\s%preun\n%vagrant_plugin_unregister %\{vagrant_plugin_name\}/, @out_string)
  end

  def test_file_list
    assert_match(/\s%dir %\{vagrant_plugin_instdir\}/, @out_string)
    assert_match(/\s%\{vagrant_plugin_libdir\}/, @out_string)
    assert_match(/\s%\{vagrant_plugin_spec\}/, @out_string)
    assert_match(/\s%doc %\{vagrant_plugin_docdir\}/, @out_string)
    assert_match(/\s%license %\{vagrant_plugin_instdir\}\/MIT/, @out_string)
    assert_match(/\s%doc %\{vagrant_plugin_instdir\}\/AUTHORS/, @out_string)
  end
end
