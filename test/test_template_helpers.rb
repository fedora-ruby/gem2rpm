require 'helper'
require 'gem2rpm/template_helpers'

class ConcreteTemplateHelpers
  extend Gem2Rpm::TemplateHelpers
end

class TestTemplateHelpers < Minitest::Test
  def test_requirement
    assert_equal "rubygem(foo)", ConcreteTemplateHelpers.requirement("rubygem(foo)")
    assert_equal "rubygem(foo) >= 1.0", ConcreteTemplateHelpers.requirement("rubygem(foo)", ">= 1.0")
    assert_equal "rubygem(foo)", ConcreteTemplateHelpers.requirement("rubygem(foo)", "")

    artificial_object = Object.new
    assert_equal "rubygem(foo)", ConcreteTemplateHelpers.requirement("rubygem(foo)", artificial_object)
  end
end
