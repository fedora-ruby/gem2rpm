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

    # RPM requires for Gem::Specification's RubyGems version
    def rubygems_requires(spec)
      requires = []
      for req in spec.required_rubygems_version
        requires << "Requires: ruby(rubygems)#{(' ' + req) unless req.empty?}"
      end
      requires.join("\n")
    end

    # RPM requires for Gem::Specification's runtime dependencies
    def gem_requires(spec)
      requires = []
      for d in spec.runtime_dependencies
        for req in d.requirement
          requires <<  "Requires: rubygem(#{d.name})#{(' ' + req) unless req.empty?}"
        end
      end
      requires.join("\n")
    end

    # RPM build requires for Gem::Specification's RubyGems version
    def rubygems_build_requires(spec)
      requires = []
      for req in spec.required_rubygems_version
        requires << "BuildRequires: rubygems-devel#{(' ' + req) unless req.empty?}"
      end
      requires.join("\n")
    end

    # RPM build requires for Gem::Specification's Ruby version
    def ruby_build_requires(spec)
      requires = []
      for req in spec.required_ruby_version
        requires << "BuildRequires: ruby#{'-devel' unless spec.extensions.empty?}" +
                    "#{(' ' + req) unless req.empty?}"
      end
      requires.join("\n")
    end

    # RPM build requires for Gem::Specification's runtime dependencies
    def gem_build_requires(spec)
      requires = []
      for d in spec.development_dependencies
        for req in d.requirement
          requires << "# BuildRequires: rubygem(#{d.name})#{(' ' + req) unless req.empty?}"
        end unless ["rdoc", "rake", "bundler"].include? d.name
      end
      requires.join("\n")
    end
  end
end
