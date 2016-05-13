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

  def test_finish_with_option_version
    hundle_options_with_capture('-v')
    assert(@config.finish?)
  end

  def test_finish_with_option_templates
    hundle_options_with_capture('--templates')
    assert(@config.finish?)
  end

  def test_finish_with_option_fetch
    hundle_options('--fetch')
    refute(@config.finish?)
  end

  def test_options
    hundle_options
    assert @config.options
    assert_includes @config.options, :args
  end

  def test_option_templates
    out, err = hundle_options_with_capture('--templates')
    assert_match(/^Available templates/, out)
    assert_match(/\AAvailable templates.*\npld\n\Z/m, out)
    assert_empty(err)
  end

  def test_option_version
    out, err = hundle_options_with_capture('-v')
    assert_match(/^\d/, out)
    assert_equal("#{Gem2Rpm::VERSION}\n", out)
    assert_empty(err)
  end

  def test_invalid_option
    assert_throws_and_match(Gem2Rpm::Configuration::ConfigurationError,
      /\Ainvalid option: -Z\n\nUsage:/m) do
      hundle_options('-Z')
    end
  end

  private

  def run_capture_io
    unless self.respond_to?(:capture_io)
      skip('Skip because capture_io is not supported.')
    end
    # Use capture_io to prevent the output to stdout, stderr.
    capture_io do
      yield
    end
  end

  def hundle_options_with_capture(string = '')
    argv = string.split

    run_capture_io do
      @config.send(:handle_options, argv)
    end
  end

  def hundle_options(string = '')
    argv = string.split
    @config.send(:handle_options, argv)
  end

  def assert_throws_and_match(clazz, message_matcher)
    begin
      yield
    rescue Exception => e
      assert(e.instance_of?(clazz))
      assert_match(message_matcher, e.to_s)
      return
    end
    assert(false)
  end
end
