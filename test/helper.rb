TEST_DIR = File.expand_path(File.dirname(__FILE__))
ROOT_DIR = File.expand_path(File.join(TEST_DIR, ".."))
$LOAD_PATH.unshift File.join(ROOT_DIR, "lib")

require 'rubygems'
require 'rubygems/version'

require 'minitest/autorun'

require 'gem2rpm'

# If you want to test in off line environment, set environment variable.
def local_test?
  @is_local_test = ENV['TEST_GEM2RPM_LOCAL']
end

def skip_if_offline
  skip('Skip test because of off line') if local_test?
end

def config
  Gem2Rpm::Configuration.instance
end

def testing_tmp_dir
  @testing_tmp_dir ||= File.join(ROOT_DIR, "tmp")
end

def bin_gem2rpm_path
  @bin_gem2rpm_path ||= File.join(ROOT_DIR, "bin", "gem2rpm")
end

def gem_file_name
  @gem_file_name ||= "testing_gem-1.0.0.gem"
end

def gem_path
  @gem_path ||= File.join(TEST_DIR,
    "artifacts", "testing_gem", gem_file_name)
end

def error_gem_file_name
  @error_gem_file_name ||= "testing_gem_error-1.0.0.gem"
end

def error_gem_path
  @error_gem_path ||= File.join(TEST_DIR,
    "artifacts", "testing_gem", error_gem_file_name)
end

def vagrant_plugin_path
  @vagrant_plugin_path ||= File.join(TEST_DIR,
    "artifacts", "vagrant_plugin", "vagrant_plugin-1.0.0.gem")
end
