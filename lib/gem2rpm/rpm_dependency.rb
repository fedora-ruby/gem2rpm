module Gem2Rpm
  class RpmDependency
    def initialize(dependency)
      @dependency = dependency.dup

      unless dependency.respond_to? :__getobj__
        @dependency = Gem2Rpm::Dependency.new @dependency
      end
    end

    # Convert to rubygem() virtual provide dependency.
    def virtualize
      dep = @dependency.dup
      dep.name = "rubygem(#{dep.name})"

      self.class.new dep
    end

    # Output dependency with RPM requires tag.
    def with_requires
      dep = @dependency.dup
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
      dep = @dependency.dup
      dep.name = "# #{dep.name}"

      self.class.new dep
    end

    # Returns string with entry suitable for RPM .spec file.
    def to_rpm
      rpm_dependencies = @dependency.requirement.map do |version|
        version = nil if version && version.to_s.empty?
        [@dependency.name, version].compact.join(' ')
      end
      rpm_dependencies.join("\n")
    end
  end
end
