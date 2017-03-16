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

  def test_reject
    file_to_exclude = files.last

    new_file_list = @file_list.reject { |file| file == file_to_exclude }

    assert_equal @file_list.entries.size - 1, new_file_list.entries.size
    refute_includes new_file_list, file_to_exclude

    assert_instance_of Gem2Rpm::RpmFileList, new_file_list
    refute_same @file_list, new_file_list
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

  def test_license
    license_files = %w(License.rdoc)

    file_list = Gem2Rpm::RpmFileList.new(license_files)

    assert_equal license_files, file_list.main_entries.entries
    assert_empty file_list.doc_entries.entries
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
