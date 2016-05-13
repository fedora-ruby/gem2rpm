require 'helper'

class TestConfiguration < Minitest::Test
  def setup
    @config = Gem2Rpm::Configuration.instance
  end

  def test_change_in_configuration_keep_default_untouched
    skip("TODO: The DEFAULT_RULES must be deep cloned!")
    @config.rule_for(:doc) << 'foo'
    refute_includes Gem2Rpm::Configuration::DEFAULT_RULES[:doc], 'foo'
  end

  def test_options
    setup_options
    assert @config.options
    assert_includes @config.options, :args
  end

  def test_option_templates
    setup_options('--templates')
    assert(@config.options)
    assert_includes(@config.options, :templates)
  end

  def test_option_version
    setup_options('-v')
    assert(@config.options)
    assert_includes(@config.options, :version)
  end

  def test_invalid_option
    e = assert_raises(Gem2Rpm::Configuration::InvalidOption) do
      setup_options('-Z')
    end
    assert_match(/\Ainvalid option: -Z\n\nUsage:/m, e.to_s)
  end

  private

  def setup_options(string = '')
    argv = string.split
    @config.send(:handle_options, argv)
  end
end
