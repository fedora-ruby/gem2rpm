$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'rubygems'
require 'rubygems/version'

require 'minitest/autorun'

require 'gem2rpm'

# If you want to test in off line environment, set environment variable.
def skip_if_offline
  skip('Skip test because of off line') if ENV['TEST_GEM2RPM_LOCAL']
end

def config
  # Templates might modify the configuration, better to reset it.
  Gem2Rpm::Configuration.instance.reset
end

def gem_path
  @gem_path ||= begin
    path = File.join(File.dirname(__FILE__), "artifacts", "testing_gem")
    Dir.chdir path do
      `gem build testing_gem.gemspec`
    end
    File.join(path, "testing_gem-1.0.0.gem")
  end
end

def vagrant_plugin_path
  @vagrant_plugin_path ||= File.join(File.dirname(__FILE__), "artifacts", "vagrant_plugin", "vagrant_plugin-1.0.0.gem")
end
