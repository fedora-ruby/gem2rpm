module Gem2Rpm
  module TemplateHelpers
    # File list block for the main package
    def main_file_entries(spec)
      entries = Helpers.top_level_from_file_list(spec.files)
      entries.delete_if{ |f| Helpers.doc_file?(f) || Helpers.misc_file?(f) }
      Helpers.file_entries_to_rpm(entries)
    end

    # File list block for the doc sub-package
    def doc_file_entries(spec)
      entries = Helpers.top_level_from_file_list(spec.files)
      entries.keep_if{ |f| Helpers.doc_file?(f) || Helpers.misc_file?(f) }
      Helpers.file_entries_to_rpm(entries)
    end
  end
end
