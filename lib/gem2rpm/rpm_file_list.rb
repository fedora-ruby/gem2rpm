require 'gem2rpm/rpm_file'

module Gem2Rpm
  class RpmFileList
    include Enumerable

    # Returns a new file list created from the array of files (e.g.
    # Gem2Rpm::Specification.files).
    def initialize(files)
      @items = files.map { |f| RpmFile.new(f) }
    end

    # Calls the given block once for each element in self, passing that
    # element as a parameter. Returns the array itself.
    # If no block is given, an Enumerator is returned.
    def each
      # Return Enumerator when called withoug block.
      return to_enum(__callee__) unless block_given?

      @items.each { |item| yield item }
    end

    # Returns a new array containing the items in self for which the given
    # block is not true. The ordering of non-rejected elements is maintained.
    # If no block is given, an Enumerator is returned instead.
    def reject
      # Return Enumerator when called withoug block.
      return to_enum(__callee__) unless block_given?

      self.class.new(@items.reject { |item| yield item })
    end

    # Returns a list of top level directories and files, omit all subdirectories.
    def top_level_entries
      self.class.new(entries.map { |f| f.gsub!(/([^\/]*).*/, '\1') }.uniq)
    end

    # Returns new list of files suitable for main.
    def main_entries
      self.class.new(entries.delete_if { |f| (f.doc? && !f.license?) || f.misc? || f.test? })
    end

    # Returns new list of files suitable for -doc subpackage.
    def doc_entries
      self.class.new(entries.delete_if { |f| !((f.doc? && !f.license?) || f.misc? || f.test?) })
    end

    # Returns string with all files from the list converted into entries
    # suitable for RPM .spec file. Thise entries should include all necessary
    # macros depending on file categorization.
    def to_rpm
      entries.map(&:to_rpm).join("\n")
    end
  end
end
