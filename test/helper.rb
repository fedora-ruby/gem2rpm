$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'rubygems'
require 'rubygems/version'

require 'minitest/autorun'

require 'gem2rpm'

def config
  Gem2Rpm::Configuration.instance
end

def gem_path
  @gem_path ||= File.join(File.dirname(__FILE__), "artifacts", "testing_gem", "testing_gem-1.0.0.gem")
end

def vagrant_plugin_path
  @vagrant_plugin_path ||= File.join(File.dirname(__FILE__), "artifacts", "vagrant_plugin", "vagrant_plugin-1.0.0.gem")
end
