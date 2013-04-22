require 'helper'
require 'stringio'

class TestGem2Rpm < Test::Unit::TestCase

  Dir.glob(File.join(File.dirname(__FILE__), '..', 'templates', '*')).each do |t|
    template_name = File.basename(t)[/\w+/]
    template = File.read t

    define_method :"test_#{template_name}_omitting_development_requirements_from_spec" do
      # Only run this test if rubygems 1.2.0 or later.
      if Gem::Version.create(Gem::RubyGemsVersion) >= Gem::Version.create("1.2.0")
        out = StringIO.new

        Gem2Rpm::convert(gem_path, template, out, false)

        assert_no_match(/\sRequires: rubygem\(test_development\)/, out.string)
      end
    end
  end

  # TODO: Make this test work offline.
  def test_find_download_url_for_source_address
    assert_match %r{http://rubygems.org/gems/}, Gem2Rpm::find_download_url("gem2rpm", "0.8.0")
  end

end
