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
      dep = __getobj__.dup
      dep.name = "rubygem(#{dep.name})"

      self.class.new dep
    end

    # Output dependency with RPM requires tag.
    def with_requires
      dep = __getobj__.dup
      dep.name = case dep.type
      when :development
        "BuildRequires: #{dep.name}"
      else
        "Requires: #{dep.name}"
      end

      self.class.new dep
    end

    # Comment out the dependency.
    def comment_out
      dep = __getobj__.dup
      dep.name = "# #{dep.name}"

      self.class.new dep
    end

    # Returns string with entry suitable for RPM .spec file.
    def to_rpm
      rpm_dependencies = requirement.map do |version|
        version = nil if version && version.to_s.empty?
        [name, version].compact.join(' ')
      end
      rpm_dependencies.join("\n")
    end

    def with_range_of_dependencies
      dep = __getobj__.dup

      rpm_dependencies = requirement.map do |version|
        next if version && version.to_s.empty?
        [dep.name, version].compact.join(' ')
      end
      dependencies_string = rpm_dependencies.compact.uniq.join(' with ')
      dependencies_string.prepend('(').concat(')') if requirement.size > 1

      dep.name = dependencies_string
      self.class.new dep
    end

    def to_string
      name.to_s
    end
  end
end
