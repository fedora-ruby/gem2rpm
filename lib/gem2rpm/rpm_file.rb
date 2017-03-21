require 'pathname'
require 'gem2rpm/helpers'

module Gem2Rpm
  class RpmFile < String
    # Returns string with entry suitable for RPM .spec file. This typically
    # includes all necessary macros depending on file categorization.
    def to_rpm
      config = Gem2Rpm::Configuration.instance

      case
      when license?
        "#{config.macro_for(:license)} #{config.macro_for(:instdir)}/#{self}".strip
      when doc?
        "#{config.macro_for(:doc)} #{config.macro_for(:instdir)}/#{self}".strip
      when ignore?
        "#{config.macro_for(:ignore)} #{config.macro_for(:instdir)}/#{self}".strip
      # /lib should have its own macro
      when self == 'lib'
        "#{config.macro_for(:libdir)}"
      else
        "#{config.macro_for(:instdir)}/#{self}"
      end
    end

    # Returs true for documentation files.
    def doc?
      Helpers.check_str_on_conditions(self, Gem2Rpm::Configuration.instance.rule_for(:doc))
    end

    # Returns true for license files.
    def license?
      Helpers.check_str_on_conditions(self, Gem2Rpm::Configuration.instance.rule_for(:license))
    end

    # Returns true for files which should be ommited from the package.
    def ignore?
      Helpers.check_str_on_conditions(self, Gem2Rpm::Configuration.instance.rule_for(:ignore))
    end

    # Returns true for files which are part of package test suite.
    def test?
      Helpers.check_str_on_conditions(self, Gem2Rpm::Configuration.instance.rule_for(:test))
    end

    # Returns true for other known miscellaneous files.
    def misc?
      Helpers.check_str_on_conditions(self, Gem2Rpm::Configuration.instance.rule_for(:misc))
    end
  end
end
