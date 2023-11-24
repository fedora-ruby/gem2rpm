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

    # Returns string with entry suitable for RPM .spec file with RPM 4.14+.
    def to_rich_rpm(with_requires: false, commented_out: false)
      rpm_dependencies = requirement.map do |version|
        version.to_s.empty? ? name : "#{name} #{version}"
      end
      result = rpm_dependencies.size == 1 ? rpm_dependencies.first : "(#{rpm_dependencies.join(' with ')})"

      if with_requires
        result.prepend(__getobj__.type == :development ? 'BuildRequires: ' : 'Requires: ')
      end

      if commented_out
        result.prepend('# ')
      end

      result
    end
  end
end
