require 'helper'
require 'gem2rpm/helpers'

class TestHelpers < Minitest::Test
  def test_simple_conversion
    r = Gem::Requirement.new("> 1.0")
    assert_equal(["> 1.0"], Gem2Rpm::Helpers.requirement_versions_to_rpm(r))
  end

  def test_match_any_version_conversion
    r = Gem::Requirement.default
    assert_equal([""], Gem2Rpm::Helpers.requirement_versions_to_rpm(r))
  end

  def test_match_ranged_version_conversion
    r = Gem::Requirement.new(["> 1.2", "< 2.0"])
    assert_equal(["> 1.2", "< 2.0"], Gem2Rpm::Helpers.requirement_versions_to_rpm(r))
  end

  def test_first_level_pessimistic_version_constraint
    r = Gem::Requirement.new(["~> 1.2"])
    assert_equal(["=> 1.2", "< 2"], Gem2Rpm::Helpers.requirement_versions_to_rpm(r))
  end

  def test_second_level_pessimistic_version_constraint
    r = Gem::Requirement.new(["~> 1.2.3"])
    assert_equal(["=> 1.2.3", "< 1.3"], Gem2Rpm::Helpers.requirement_versions_to_rpm(r))
  end

  def test_pessimistic_version_constraint_with_trailing_text
    # Trailing text was only allowed starting around rubygems 1.3.2.
    gem_version = Gem::Version.create(Gem::RubyGemsVersion)
    if gem_version >= Gem::Version.create("1.3.2")
      r = Gem::Requirement.new(["~> 1.2.3.beta.8"])
      assert_equal(["=> 1.2.3.beta.8", "< 1.3"], Gem2Rpm::Helpers.requirement_versions_to_rpm(r))
    end
  end

  def test_second_level_pessimistic_version_constraint_with_two_digit_version
    r = Gem::Requirement.new(["~> 1.12.3"])
    assert_equal(["=> 1.12.3", "< 1.13"], Gem2Rpm::Helpers.requirement_versions_to_rpm(r))
  end

  def test_first_level_not_equal_version_constraint
    r = Gem::Requirement.new(["!= 1.2"])
    assert_equal(["< 1.2", "> 1.2"], Gem2Rpm::Helpers.requirement_versions_to_rpm(r))
  end

  def test_second_level_not_equal_version_constraint
    r = Gem::Requirement.new(["!= 1.2.3"])
    assert_equal(["< 1.2.3", "> 1.2.3"], Gem2Rpm::Helpers.requirement_versions_to_rpm(r))
  end

  def test_file_entries_to_rpm
    entries = ['lib/foo.rb', 'LICENSE']
    result = "#{config.macro_for(:instdir)}/#{entries[0]}\n" \
             "#{config.macro_for(:license)} #{config.macro_for(:instdir)}/#{entries[1]}"
    assert_equal result, Gem2Rpm::Helpers.file_entries_to_rpm(entries)

    entries = ['.gitignore', 'AUTHORS']
    result = "#{config.macro_for(:ignore)} #{config.macro_for(:instdir)}/#{entries[0]}\n" \
             "#{config.macro_for(:doc)} #{config.macro_for(:instdir)}/#{entries[1]}"
    assert_equal result, Gem2Rpm::Helpers.file_entries_to_rpm(entries)
  end

  def test_file_entry_to_rpm
    entry = 'lib/foo/bar.rb'
    result = "#{config.macro_for(:instdir)}/#{entry}"
    assert_equal result, Gem2Rpm::Helpers.file_entry_to_rpm(entry)
  end

  def test_top_level_from_file_list
    file_list = ['foo.rb', 'first/bar.rb', 'first/second/bar.rb', 'first/foo.rb']
    assert_equal ['foo.rb', 'first'], Gem2Rpm::Helpers.top_level_from_file_list(file_list)
  end

  def test_check_str_on_conditions
    conditions = [/\/?CHANGELOG.*/i, 'FILE']
    str = 'CHANGELOG'
    assert_equal true, Gem2Rpm::Helpers.check_str_on_conditions(str, conditions)
    str = 'FILE'
    assert_equal true, Gem2Rpm::Helpers.check_str_on_conditions(str, conditions)
  end
end
