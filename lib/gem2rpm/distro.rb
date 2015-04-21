module Gem2Rpm
  class Distro
    FEDORA = :fedora
    PLD = :pld
    OPENSUSE = :opensuse
    DEFAULT = :default
    ROLLING_RELEASES = ['rawhide', 'factory', 'tumbleweed']

    def self.nature
      if !release_files.grep(/fedora/).empty?
        versions = []

        release_files.each do |file|
          /\d+/ =~ File.open(file, OPEN_MODE).readline
          versions << Regexp.last_match.to_s if Regexp.last_match
        end

        versions.uniq!

        if versions.length == 1
          template_by_os_version(FEDORA, versions.first) || FEDORA
        else # no version or more versions (=> don't know what to do)
          FEDORA
        end
      elsif !release_files.grep(/redhat/).empty?
        # Use Fedora's template for RHEL ATM.
        FEDORA
      elsif !release_files.grep(/SuSE/).empty?
        OPENSUSE
      elsif !release_files.grep(/pld/).empty?
        PLD
      else
        DEFAULT
      end
    end

    def self.release_files
      @@release_files ||=
        Dir.glob('/etc/*{_version,-release}*').select {|e| File.file? e}
    end

    def self.release_files=(files)
      @@release_files = files
    end

    def self.template_by_os_version(os, version)
      Template.list.each do |file|
        next if file =~ /^\./
        # We want only distro RubyGems templates to get the right versions
        next unless file =~ /^#{os}((-([0-9]+\.{0,1}[0-9]+){0,}){0,}(-(#{ROLLING_RELEASES.join('|')})){0,1}).spec.erb/
        return file.gsub('.spec.erb', '') if Regexp.last_match and in_range?(version, Regexp.last_match[1].to_s.split('-').drop(1))
      end

      nil
    end

    def self.in_range?(version, range)
      return nil unless range

      if range.length == 1
        return true if range.first.to_s == version.to_s
      else # range: [xx, yy]
        if range[0].to_s <= version.to_s
          return true if ROLLING_RELEASES.include? range[1] or version.to_s <= range[1].to_s
        end
      end

      false
    end
  end
end
