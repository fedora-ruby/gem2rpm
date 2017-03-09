require 'helper'
require 'gem2rpm/rpm_file_list'

class TestRpmFileList < Minitest::Test
  def test_top_level_from_file_list
    file_list = ['foo.rb', 'first/bar.rb', 'first/second/bar.rb', 'first/foo.rb']
    assert_equal ['foo.rb', 'first'], Gem2Rpm::RpmFileList.new(file_list).entries
  end

  def test_to_rpm
    entries = [
      'lib/foo.rb',
      'lib/bar.rb',
      'lib/bar/baz.rb',
      'LICENSE',
      '.gitignore',
      'AUTHORS',
    ]
    results =
      "#{config.macro_for(:libdir)}\n" \
      "#{config.macro_for(:license)} #{config.macro_for(:instdir)}/#{entries[3]}\n" \
      "#{config.macro_for(:ignore)} #{config.macro_for(:instdir)}/#{entries[4]}\n" \
      "#{config.macro_for(:doc)} #{config.macro_for(:instdir)}/#{entries[5]}"

    assert_equal results, Gem2Rpm::RpmFileList.new(entries).to_rpm
  end

end
