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
