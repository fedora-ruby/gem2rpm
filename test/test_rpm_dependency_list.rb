require 'helper'

require 'gem2rpm/rpm_dependency_list'

class TestRpmDependencyList < Minitest::Test
  def setup
    @dependency_list = Gem2Rpm::RpmDependencyList.new(entries)
  end

  def entries
    @entries ||= [
      Gem::Dependency.new('empty_requirement'),
      Gem::Dependency.new('pessimistic_constraint', Gem::Requirement.new('~> 1.0')),
      Gem::Dependency.new('development_dependency', :development)
    ]
  end

  def test_to_rpm
    result =
      "empty_requirement\n" \
      "pessimistic_constraint >= 1.0\npessimistic_constraint < 2\n" \
      "development_dependency"

    assert_equal result, @dependency_list.to_rpm
  end

  def test_virtualize
    result =
      "rubygem(empty_requirement)\n" \
      "rubygem(pessimistic_constraint) >= 1.0\nrubygem(pessimistic_constraint) < 2\n" \
      "rubygem(development_dependency)"

    assert_equal result, @dependency_list.virtualize.to_rpm
  end
end
