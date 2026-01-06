require 'gem2rpm/gem/dependency'

module Gem2Rpm
  class RpmDependency < Gem2Rpm::Dependency
    attr_reader :boolean

    def initialize(dependency)
      @boolean = dependency.boolean if dependency.respond_to? :boolean

      if dependency.respond_to? :__getobj__
        super dependency.__getobj__
      else
        super
      end
    end

    # Convert to rubygem() virtual provide dependency.
    def virtualize
      clone.tap do |dep|
        if dep.boolean
          dep.instance_variable_set('@boolean', "rubygem(#{dep.name})")
        else
          dep.name = "rubygem(#{dep.name})"
        end
      end
    end

    # Output dependency with RPM requires tag.
    def with_requires
      clone.tap do |dep|
        prefix = case dep.type
        when :development
          "BuildRequires:"
        else
          "Requires:"
        end

        if dep.boolean
          dep.instance_variable_set('@boolean', "#{prefix} #{dep.boolean}")
        else
          dep.name = "#{prefix} #{dep.name}"
        end
      end
    end

    # Comment out the dependency.
    def comment_out
      clone.tap do |dep|
        if dep.boolean
          dep.instance_variable_set('@boolean', "# #{dep.boolean}")
        else
          dep.name = "# #{dep.name}"
        end
      end
    end

    # Represent as boolean RPM dependency.
    def booleanize
      clone.tap do |dep|
        rpm_dependencies = requirement.map do |version|
          version = nil if version && version.to_s.empty?
          [name, version].compact.join(' ')
        end

        rpm_dependencies = rpm_dependencies.join(' with ')
        if requirement.size > 1
           rpm_dependencies = "(#{rpm_dependencies})"
        end

        dep.instance_variable_set('@boolean', rpm_dependencies)
      end
    end

    # Returns string with entry suitable for RPM .spec file.
    def to_rpm
      boolean || requirement.map do |version|
        version = nil if version && version.to_s.empty?
        [name, version].compact.join(' ')
      end.join("\n")
    end
  end
end
