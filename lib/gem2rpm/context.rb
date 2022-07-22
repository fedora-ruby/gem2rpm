require 'gem2rpm/template_helpers'

module Gem2Rpm
  class Context
    include Gem2Rpm::TemplateHelpers

    attr_reader :nongem, :local, :doc_subpackage, :package, :format, :spec,
      :config, :runtime_dependencies, :development_dependencies, :tests,
      :files, :download_path

    def initialize(fname, nongem = true, local = false, doc_subpackage = true)
      @nongem = nongem
      @local = local
      @doc_subpackage = doc_subpackage

      @package = Gem2Rpm::Package.new(fname)
      # Deprecate, kept just for backward compatibility.
      @format = Gem2Rpm::Format.new(@package)
      @spec = Gem2Rpm::Specification.new(@package.spec)

      @config = Configuration.instance.reset

      @runtime_dependencies = Gem2Rpm::RpmDependencyList.new(@spec.runtime_dependencies)
      @development_dependencies = Gem2Rpm::RpmDependencyList.new(@spec.development_dependencies)

      @tests = TestSuite.new(spec)

      # Ruby 2.0 doesn't have sorted files
      @files = RpmFileList.new(spec.files.sort)

      @download_path = ""
      unless @local
        begin
          @download_path = Gem2Rpm.find_download_url(@spec.name, @spec.version)
        rescue DownloadUrlError => e
          $stderr.puts "Warning: Could not retrieve full URL for #{@spec.name}\nWarning: Edit the specfile and enter the full download URL as 'Source0' manually"
          $stderr.puts e.inspect
        end
      end
    end

    def main_files
      @files.top_level_entries.main_entries
    end

    def doc_files
      @files.top_level_entries.doc_entries
    end

    def packager
      Gem2Rpm.packager
    end
  end
end
