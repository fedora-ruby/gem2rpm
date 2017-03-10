require 'helper'
require 'gem2rpm/rpm_file_list'

class TestRpmFileList < Minitest::Test
  def file_list
    %w(
      lib/foo.rb
      lib/bar.rb
      lib/bar/baz.rb
      LICENSE
      .gitignore
      AUTHORS
    )
  end

  def test_converts_to_rpm_files
    Gem2Rpm::RpmFileList.new(file_list).entries.each do |e|
      assert_instance_of Gem2Rpm::RpmFile, e
    end
  end

  def test_top_level_entries
    assert_equal ['lib', 'LICENSE', '.gitignore', 'AUTHORS'],
      Gem2Rpm::RpmFileList.new(file_list).top_level_entries.to_a
  end

  def test_to_rpm
    results =
      "#{config.macro_for(:instdir)}/#{file_list[0]}\n" \
      "#{config.macro_for(:instdir)}/#{file_list[1]}\n" \
      "#{config.macro_for(:instdir)}/#{file_list[2]}\n" \
      "#{config.macro_for(:license)} #{config.macro_for(:instdir)}/#{file_list[3]}\n" \
      "#{config.macro_for(:ignore)} #{config.macro_for(:instdir)}/#{file_list[4]}\n" \
      "#{config.macro_for(:doc)} #{config.macro_for(:instdir)}/#{file_list[5]}"

    assert_equal results, Gem2Rpm::RpmFileList.new(file_list).to_rpm
  end

end
