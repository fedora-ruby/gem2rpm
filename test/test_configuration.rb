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
    assert @config.options
    assert_includes @config.options, :args
  end
end
