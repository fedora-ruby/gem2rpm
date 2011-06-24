require 'delegate'

module Gem2Rpm
  class Specification < SimpleDelegator
    # A long description of gem wrapped to 78 characters.
    def description
      word_wrap(super.to_s.chomp, 78) + "\n"
    end

    # The RubyGems version required by gem. For RubyGems < 0.9.5 returns only
    # empty string. However, this should happen only in rare cases.
    def required_rubygems_version
      super.to_rpm
    rescue
      ['']
    end

  private

    # Taken with modification from the word_wrap method in ActionPack.
    # Text::Format does the same thing better.
    def word_wrap(text, line_width = 80)
      text.gsub(/\n/, "\n\n").gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip
    end
  end
end
