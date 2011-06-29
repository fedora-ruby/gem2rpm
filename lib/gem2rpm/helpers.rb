module Gem2Rpm
  module Helpers
    # Taken with modification from the word_wrap method in ActionPack.
    # Text::Format does the same thing better.
    def self.word_wrap(text, line_width = 80)
      text.gsub(/\n/, "\n\n").gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip
    end

    # Expands the pesimistic version operator '~>' into equivalent '>=' and
    # '<' pair.
    def self.expand_pessimistic_requirement(requirements)
      requirements.inject([]) do |output, r|
        if r.first == '~>'
	  next_version = Gem::Version.create(r.last).bump
	  output << ['=>', r.last]
	  output << ['<', next_version]
	else
	  output << r
	end
      end
    end

    # Converts Gem::Requirement into array of requirements strings compatible
    # with RPM .spec file.
    def self.requirement_versions_to_rpm(requirement)
      self.expand_pessimistic_requirement(requirement.requirements).map do |op, version|
        version == Gem::Version.new(0) ? "" : "#{op} #{version}"
      end
    end
  end
end
