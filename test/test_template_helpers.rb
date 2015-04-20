require 'helper'
require 'gem2rpm/template_helpers'

class TestTemplateHelpers < Minitest::Test
  def test_requirement
    assert_equal "rubygem(foo)", Gem2Rpm.requirement("rubygem(foo)")
    assert_equal "rubygem(foo) >= 1.0", Gem2Rpm.requirement("rubygem(foo)", ">= 1.0")
    assert_equal "rubygem(foo)", Gem2Rpm.requirement("rubygem(foo)", "")

    artificial_object = Object.new
    assert_equal "rubygem(foo) #{artificial_object}", Gem2Rpm.requirement("rubygem(foo)", artificial_object)
  end
end
