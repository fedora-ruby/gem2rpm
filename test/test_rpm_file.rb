require 'helper'
require 'gem2rpm/rpm_file'

class TestRpmFile < Minitest::Test
  def test_to_rpm
    entries = [
      'lib/foo.rb',
      'LICENSE',
      'License.rdoc',
      '.gitignore',
      'AUTHORS',
    ]
    results = [
      "#{config.macro_for(:instdir)}/#{entries[0]}",
      "#{config.macro_for(:license)} #{config.macro_for(:instdir)}/#{entries[1]}",
      "#{config.macro_for(:license)} #{config.macro_for(:instdir)}/#{entries[2]}",
      "#{config.macro_for(:ignore)} #{config.macro_for(:instdir)}/#{entries[3]}",
      "#{config.macro_for(:doc)} #{config.macro_for(:instdir)}/#{entries[4]}",
    ]

    assert_equal results, entries.map { |e| Gem2Rpm::RpmFile.new(e).to_rpm }
  end
end
