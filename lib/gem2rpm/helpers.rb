module Gem2Rpm
  module Helpers
    # Taken with modification from the word_wrap method in ActionPack.
    # Text::Format does the same thing better.
    def self.word_wrap(text, line_width = 80)
      text.gsub(/\n/, "\n\n").gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip
    end

    # Expands '~>' and '!=' gem requirements.
    def self.expand_requirement(requirements)
      requirements.inject([]) do |output, r|
        output.concat case r.first
        when '~>'
          expand_pessimistic_requirement(r)
        when '!='
          expand_not_equal_requirement(r)
        else
          [r]
        end
      end
    end

    # Expands the pessimistic version operator '~>' into equivalent '>=' and
    # '<' pair.
    def self.expand_pessimistic_requirement(requirement)
      next_version = Gem::Version.create(requirement.last).bump
      return ['=>', requirement.last], ['<', next_version]
    end

    # Expands the not equal version operator '!=' into equivalent '<' and
    # '>' pair.
    def self.expand_not_equal_requirement(requirement)
      return ['<', requirement.last], ['>', requirement.last]
    end

    # Converts Gem::Requirement into array of requirements strings compatible
    # with RPM .spec file.
    def self.requirement_versions_to_rpm(requirement)
      self.expand_requirement(requirement.requirements).map do |op, version|
        version == Gem::Version.new(0) ? "" : "#{op} #{version}"
      end
    end
  end
end
