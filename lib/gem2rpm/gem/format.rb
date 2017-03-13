require 'delegate'

module Gem2Rpm
  class Format < SimpleDelegator
    # Returns the value of attribute gem_path
    def gem_path
      super
    rescue
      spec.file_name
    end

    # Returns the value of attribute file_entries
    def file_entries
      super
    rescue
      spec.files
    end
  end
end
