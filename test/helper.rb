$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'test/unit'
require 'rubygems'
require 'rubygems/version'
require 'gem2rpm'

def gem_path
  @gem_path ||= File.join(File.dirname(__FILE__), "artifacts", "testing_gem", "testing_gem-1.0.0.gem")
end
