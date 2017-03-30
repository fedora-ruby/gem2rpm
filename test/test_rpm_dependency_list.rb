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

  def test_reject
    result =
      "empty_requirement\n" \
      "development_dependency\n"

    dependency_to_exclude = entries[1]

    new_dependency_list = @dependency_list.reject { |d| d == dependency_to_exclude }

    assert_equal @dependency_list.entries.size - 1, new_dependency_list.entries.size
    refute_includes new_dependency_list, dependency_to_exclude

    assert_instance_of Gem2Rpm::RpmDependencyList, new_dependency_list
    refute_same @dependency_list, new_dependency_list

    assert_equal result, new_dependency_list.to_rpm
  end

  def test_to_rpm
    result =
      "empty_requirement\n" \
      "pessimistic_constraint >= 1.0\npessimistic_constraint < 2\n" \
      "development_dependency\n"

    assert_equal result, @dependency_list.to_rpm
  end

  def test_virtualize
    result =
      "rubygem(empty_requirement)\n" \
      "rubygem(pessimistic_constraint) >= 1.0\nrubygem(pessimistic_constraint) < 2\n" \
      "rubygem(development_dependency)\n"

    assert_equal result, @dependency_list.virtualize.to_rpm
  end

  def test_with_requires
    result =
      "Requires: empty_requirement\n" \
      "Requires: pessimistic_constraint >= 1.0\nRequires: pessimistic_constraint < 2\n" \
      "BuildRequires: development_dependency\n"

    assert_equal result, @dependency_list.with_requires.to_rpm
  end

  def test_comment_out
    result =
      "# empty_requirement\n" \
      "# pessimistic_constraint >= 1.0\n# pessimistic_constraint < 2\n" \
      "# development_dependency\n"

    assert_equal result, @dependency_list.comment_out.to_rpm
  end
end
