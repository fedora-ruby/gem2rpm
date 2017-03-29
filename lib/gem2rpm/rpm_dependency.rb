module Gem2Rpm
  class RpmDependency
    attr_reader :gem_dependency

    def initialize(dependency)
      @gem_dependency = dependency.dup

      unless dependency.respond_to? :__getobj__
        @gem_dependency = Gem2Rpm::Dependency.new @gem_dependency
      end
    end

    # Returns name of the dependency.
    def name
      @gem_dependency.name
    end

    # Provides list of requirements of this dependency.
    def requirement
      @gem_dependency.requirement
    end

    # Convert to rubygem() virtual provide dependency.
    def virtualize
      dep = @gem_dependency.dup
      dep.name = "rubygem(#{dep.name})"

      self.class.new dep
    end

    # Output dependency with RPM requires tag.
    def with_requires
      dep = @gem_dependency.dup
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
      dep = @gem_dependency.dup
      dep.name = "# #{dep.name}"

      self.class.new dep
    end

    # Returns string with entry suitable for RPM .spec file.
    def to_rpm
      rpm_dependencies = @gem_dependency.requirement.map do |version|
        version = nil if version && version.to_s.empty?
        [@gem_dependency.name, version].compact.join(' ')
      end
      rpm_dependencies.join("\n")
    end
  end
end
