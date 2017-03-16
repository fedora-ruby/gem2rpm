require 'pathname'
require 'gem2rpm/helpers'

module Gem2Rpm
  class RpmFile < String
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

    def doc?
      Helpers.check_str_on_conditions(self, Gem2Rpm::Configuration.instance.rule_for(:doc))
    end

    def license?
      Helpers.check_str_on_conditions(self, Gem2Rpm::Configuration.instance.rule_for(:license))
    end

    def ignore?
      Helpers.check_str_on_conditions(self, Gem2Rpm::Configuration.instance.rule_for(:ignore))
    end

    def test?
      Helpers.check_str_on_conditions(self, Gem2Rpm::Configuration.instance.rule_for(:test))
    end

    def misc?
      Helpers.check_str_on_conditions(self, Gem2Rpm::Configuration.instance.rule_for(:misc))
    end
  end
end
