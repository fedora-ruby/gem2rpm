require 'helper'
require 'stringio'

class TestGem2Rpm < Minitest::Test
  def setup
    @out = StringIO.new
  end

  Dir.glob(File.join(File.dirname(__FILE__), '..', 'templates', '*')).each do |t|
    template_name = File.basename(t).split.first.gsub(/[.-]/, '_')
    template = Gem2Rpm::Template.new t

    define_method :"test_#{template_name}_omitting_development_requirements_from_spec" do
      # Only run this test if rubygems 1.2.0 or later.
      if Gem::Version.create(Gem::RubyGemsVersion) >= Gem::Version.create("1.2.0")
        Gem2Rpm.convert(gem_path, template, @out, false)

        refute_match(/\sRequires: rubygem\(test_development\)/, @out.string)
      end
    end
  end

  def test_show_message_for_message
    expected = <<-'END'
foo

    END

    Gem2Rpm.show_message("foo", nil, @out)
    assert_equal expected, @out.string
  end

  def test_show_message_for_obj
    obj = 'bar'
    Gem2Rpm.show_message("foo", obj, @out)
    assert_equal("foo\n\nbar\n", @out.string)
  end

  def test_show_templates
    Gem2Rpm::Distro.stub :nature, 'default' do
      Gem2Rpm.show_templates(@out)
    end
    assert_match(/^Available templates/, @out.string)
    assert_match(/\AAvailable templates.*\n* default\n.*\n  pld\n\Z/m, @out.string)
  end

  def test_show_version
    Gem2Rpm.show_version(@out)
    assert_match(/^\d/, @out.string)
    assert_equal("#{Gem2Rpm::VERSION}\n", @out.string)
  end

  def test_find_download_url_for_source_address
    skip_if_offline

    assert_match %r{https?://rubygems.org/gems/}, Gem2Rpm.find_download_url("gem2rpm", "0.8.0")
  end

  def test_print_dependencies
    dependencies = <<-END.gsub(/^ */, '').lines.sort
      rubygem(test_runtime) >= 1.0
      rubygem(test_runtime) < 2
      rubygem(test_runtime) >= 1.0.0
      rubygem(test_development) >= 1.0
      rubygem(test_development) < 2
      rubygem(test_development) >= 1.0.0
    END

    Gem2Rpm.print_dependencies(
      File.join(File.dirname(__FILE__), 'artifacts', 'testing_gem', 'testing_gem-1.0.0.gem'),
      @out
    )

    assert_equal dependencies, @out.string.lines.sort
  end
end
