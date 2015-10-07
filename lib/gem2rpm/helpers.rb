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
      expand_requirement(requirement.requirements).map do |op, version|
        version == Gem::Version.new(0) ? "" : "#{op} #{version}"
      end
    end

    def self.file_entries_to_rpm(entries)
      rpm_file_list = entries.map { |e| file_entry_to_rpm(e) }
      rpm_file_list.join("\n")
    end

    def self.doc_file?(file)
      check_str_on_conditions(file, Gem2Rpm::Configuration.instance.rule_for(:doc))
    end

    def self.license_file?(file)
      check_str_on_conditions(file, Gem2Rpm::Configuration.instance.rule_for(:license))
    end

    def self.ignore_file?(file)
      check_str_on_conditions(file, Gem2Rpm::Configuration.instance.rule_for(:ignore))
    end

    def self.misc_file?(file)
      check_str_on_conditions(file, Gem2Rpm::Configuration.instance.rule_for(:misc))
    end

    def self.file_entry_to_rpm(entry)
      config = Gem2Rpm::Configuration.instance
      case
      when doc_file?(entry)
        "#{config.macro_for(:doc)} #{config.macro_for(:instdir)}/#{entry}".strip
      when license_file?(entry)
        "#{config.macro_for(:license)} #{config.macro_for(:instdir)}/#{entry}".strip
      when ignore_file?(entry)
        "#{config.macro_for(:ignore)} #{config.macro_for(:instdir)}/#{entry}".strip
      # /lib should have its own macro
      when entry == 'lib'
        "#{config.macro_for(:libdir)}"
      else
        "#{config.macro_for(:instdir)}/#{entry}"
      end
    end

    # Returns a list of top level directories and files
    # out of an array of file_list
    def self.top_level_from_file_list(file_list)
      file_list.map { |f| f.gsub!(/([^\/]*).*/, '\1') }.uniq
    end

    # Compares string to the given regexp conditions
    def self.check_str_on_conditions(str, conditions)
      conditions.any? do |condition|
        condition.is_a?(Regexp) ? condition.match(str) : condition == str
      end
    end
  end
end
