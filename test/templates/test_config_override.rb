require 'helper'

class TestConfigOverride < Minitest::Test
  def test_rules_respected
    template = Gem2Rpm::Template.new(File.join(__dir__, 'fake_files', 'config-override.erb'))
    out = StringIO.new
    Gem2Rpm.convert(gem_path, template, out, false)

    expected = <<-EXPECTED.gsub(/^ */, '')
    %files
    %exclude %{gem_instdir}/.travis.yml
    %{gem_instdir}/exe
    %{gem_instdir}/ext
    %{gem_libdir}

    %files doc
    %exclude %{gem_instdir}/Gemfile
    %doc %{gem_instdir}/README
    %{gem_instdir}/Rakefile
    %{gem_instdir}/runtime
    %{gem_instdir}/testing_gem.gemspec
    EXPECTED
    assert_equal(expected, out.string)
  end
end
