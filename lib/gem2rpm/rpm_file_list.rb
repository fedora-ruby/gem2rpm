require 'gem2rpm/rpm_file'

module Gem2Rpm
  class RpmFileList
    include Enumerable

    def initialize(files)
      @items = files.map { |f| RpmFile.new(f) }
    end

    def each
      # Return Enumerator when called withoug block.
      return to_enum(__callee__) unless block_given?

      @items.each { |item| yield item }
    end

    # Returns a list of top level directories and files, omit all subdirectories.
    def top_level_entries
      self.class.new(entries.map { |f| f.gsub!(/([^\/]*).*/, '\1') }.uniq)
    end

    def main_entries
      self.class.new(entries.delete_if { |f| f.doc? || f.misc? })
    end

    def doc_entries
      self.class.new(entries.delete_if { |f| !(f.doc? || f.misc?) })
    end

    def to_rpm
      entries.map(&:to_rpm).join("\n")
    end
  end
end
