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
    assert_equal(@config.options[:args].length, 0)
  end

  def test_gem_file
    gem_file = 'test.gem'
    setup_options(gem_file)
    assert(@config.options)
    assert_includes(@config.options, :args)
    assert_equal(@config.options[:args].length, 1)
    assert_equal(@config.options[:args][0], gem_file)
  end

  def test_option_templates
    setup_options('--templates')
    assert(@config.options)
    assert_includes(@config.options, :templates)
    assert(@config.options[:templates])
  end

  def test_template
    template_file = 'fedora-21-rawhide'
    gem_file = 'test.gem'
    setup_options("-t #{template_file} #{gem_file}")
    assert(@config.options)
    assert_includes(@config.options, :template_file)
    assert_equal(@config.options[:template_file], template_file)
    assert_includes(@config.options, :args)
    assert_equal(@config.options[:args].length, 1)
    assert_equal(@config.options[:args][0], gem_file)
  end

  def test_print_current_template
    setup_options('-T')
    assert(@config.options)
    assert_includes(@config.options, :print_template_file)
    assert(@config.options[:print_template_file])
  end

  def test_fetch
    gem_name = 'test'
    setup_options("--fetch #{gem_name}")
    assert(@config.options)
    assert_includes(@config.options, :fetch)
    assert(@config.options[:fetch])
    assert_includes(@config.options, :args)
    assert_equal(@config.options[:args].length, 1)
    assert_equal(@config.options[:args][0], gem_name)
  end

  def test_srpm
    gem_file = 'test.gem'
    setup_options("-s #{gem_file}")
    assert(@config.options)
    assert_includes(@config.options, :srpm)
    assert(@config.options[:srpm])
    assert_includes(@config.options, :args)
    assert_equal(@config.options[:args].length, 1)
    assert_equal(@config.options[:args][0], gem_file)
  end

  def test_output_file
    output_file = 'test_out.spec'
    gem_file = 'test.gem'
    setup_options("-o #{output_file} #{gem_file}")
    assert(@config.options)
    assert_includes(@config.options, :output_file)
    assert_equal(@config.options[:output_file], output_file)
    assert_includes(@config.options, :args)
    assert_equal(@config.options[:args].length, 1)
    assert_equal(@config.options[:args][0], gem_file)
  end

  def test_change_directory
    dir_name = 'foo'
    gem_file = 'test.gem'
    setup_options("-C #{dir_name} #{gem_file}")
    assert(@config.options)
    assert_includes(@config.options, :directory)
    assert_equal(@config.options[:directory], dir_name)
    assert_includes(@config.options, :args)
    assert_equal(@config.options[:args].length, 1)
    assert_equal(@config.options[:args][0], gem_file)
  end

  def test_nongem
    gem_file = 'test.gem'
    setup_options("-n #{gem_file}")
    assert(@config.options)
    assert_includes(@config.options, :nongem)
    assert(@config.options[:nongem])
    assert_includes(@config.options, :args)
    assert_equal(@config.options[:args].length, 1)
    assert_equal(@config.options[:args][0], gem_file)
  end

  def test_local
    gem_file = 'test.gem'
    setup_options("-l #{gem_file}")
    assert(@config.options)
    assert_includes(@config.options, :local)
    assert(@config.options[:local])
    assert_includes(@config.options, :args)
    assert_equal(@config.options[:args].length, 1)
    assert_equal(@config.options[:args][0], gem_file)
  end

  def test_no_doc_subpackage
    gem_file = 'test.gem'
    setup_options("--no-doc #{gem_file}")
    assert(@config.options)
    assert_includes(@config.options, :doc_subpackage)
    refute(@config.options[:doc_subpackage])
    assert_includes(@config.options, :args)
    assert_equal(@config.options[:args].length, 1)
    assert_equal(@config.options[:args][0], gem_file)
  end

  def test_print_dependencies
    gem_file = 'test.gem'
    setup_options("-d #{gem_file}")
    assert(@config.options)
    assert_includes(@config.options, :deps)
    assert(@config.options[:deps])
    assert_includes(@config.options, :args)
    assert_equal(@config.options[:args].length, 1)
    assert_equal(@config.options[:args][0], gem_file)
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
