require 'helper'
require 'gem2rpm/rpm_file_list'

class TestRpmFileList < Minitest::Test
  def setup
    @file_list = Gem2Rpm::RpmFileList.new(files)
  end

  def files
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
    @file_list.entries.each do |e|
      assert_instance_of Gem2Rpm::RpmFile, e
    end
  end

  def test_top_level_entries
    assert_equal ['lib', 'LICENSE', '.gitignore', 'AUTHORS'],
      @file_list.top_level_entries.to_a
  end

  def test_to_rpm
    results =
      "#{config.macro_for(:instdir)}/#{files[0]}\n" \
      "#{config.macro_for(:instdir)}/#{files[1]}\n" \
      "#{config.macro_for(:instdir)}/#{files[2]}\n" \
      "#{config.macro_for(:license)} #{config.macro_for(:instdir)}/#{files[3]}\n" \
      "#{config.macro_for(:ignore)} #{config.macro_for(:instdir)}/#{files[4]}\n" \
      "#{config.macro_for(:doc)} #{config.macro_for(:instdir)}/#{files[5]}"

    assert_equal results, @file_list.to_rpm
  end
end
