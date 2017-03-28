require 'helper'
require 'gem2rpm/rpm_dependency'

class TestRpmDependency < Minitest::Test
  def entries
    @entries ||= [
      Gem::Dependency.new('empty_requirement'),
      Gem::Dependency.new('pessimistic_constraint', Gem::Requirement.new('~> 1.0'))
    ]
  end

  def results
    @results ||= [
      "empty_requirement",
      "pessimistic_constraint >= 1.0\npessimistic_constraint < 2",
    ]
  end

  def test_gem2rpm_dependency_to_rpm
    gem2rpm_dependencies = entries.map { |e| Gem2Rpm::Dependency.new e }

    assert_equal results, gem2rpm_dependencies.map { |d| Gem2Rpm::RpmDependency.new(d).to_rpm }
  end

  def test_to_rpm
    assert_equal results, entries.map { |d| Gem2Rpm::RpmDependency.new(d).to_rpm }
  end
end
