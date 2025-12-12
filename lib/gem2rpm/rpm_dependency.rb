require 'gem2rpm/gem/dependency'

module Gem2Rpm
  class RpmDependency < Gem2Rpm::Dependency
    def initialize(dependency)
      if dependency.respond_to? :__getobj__
        super dependency.__getobj__
      else
        super
      end
    end

    # Convert to rubygem() virtual provide dependency.
    def virtualize
      clone.tap do |dep|
        dep.name = "rubygem(#{dep.name})"
      end
    end

    # Output dependency with RPM requires tag.
    def with_requires
      clone.tap do |dep|
        dep.name = case dep.type
        when :development
          "BuildRequires: #{dep.name}"
        else
          "Requires: #{dep.name}"
        end
      end
    end

    # Comment out the dependency.
    def comment_out
      clone.tap do |dep|
        dep.name = "# #{dep.name}"
      end
    end

    # Returns string with entry suitable for RPM .spec file.
    def to_rpm
      rpm_dependencies = requirement.map do |version|
        version = nil if version && version.to_s.empty?
        [name, version].compact.join(' ')
      end
      rpm_dependencies.join("\n")
    end
  end
end
