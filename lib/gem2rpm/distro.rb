module Gem2Rpm
  class Distro
    FEDORA = :fedora
    PLD = :pld
    OPENSUSE = :opensuse
    DEFAULT = :default

    ROLLING_RELEASES = ['rawhide', 'factory', 'tumbleweed']

    OsRelease = Struct.new :os, :version

    def self.os_release
      @os_release ||= begin
        os_release = OsRelease.new DEFAULT

        # Try os-release first.
        if !release_files.grep(/os-release/).empty?
          content = File.open(release_files.grep(/os-release/).first, Gem2Rpm::OPEN_MODE) do |f|
            f.read
          end

          begin
            os_release.os = content[/^ID=(.*)$/, 1].to_sym
            os_release.version = content[/^VERSION_ID=(.*)$/, 1]
          rescue
          end
        end

        # If os-release failed (it is empty or has not enough information),
        # try some other release files.
        if os_release.os == DEFAULT
          if !release_files.grep(/fedora/).empty?
            os_release.os = FEDORA
            versions = []

            release_files.each do |file|
              /\d+/ =~ File.open(file, OPEN_MODE).readline
              versions << Regexp.last_match.to_s if Regexp.last_match
            end

            versions.uniq!

            os_release.version = versions.first if versions.length == 1
          elsif !release_files.grep(/redhat/).empty?
            # Use Fedora's template for RHEL ATM.
            os_release.os = FEDORA
          elsif !release_files.grep(/SuSE/).empty?
            os_release.os = OPENSUSE
          elsif !release_files.grep(/pld/).empty?
            os_release.os = PLD
          end
        end

        os_release
      end
    end

    def self.nature
      template_by_os_version(os_release.os, os_release.version) || DEFAULT
    end

    def self.release_files
      @release_files ||=
        Dir.glob('/etc/{os-release,*{_version,-release}}*').uniq.select {|e| File.file? e}
    end

    def self.release_files=(files)
      @os_release = nil
      @release_files = files
    end

    def self.template_by_os_version(os, version)
      os_templates = Template.list.grep /#{os}.*\.spec\.erb/

      os_templates.each do |file|
        # We want only distro RubyGems templates to get the right versions
        next unless file =~ /^#{os}((-([0-9]+\.{0,1}[0-9]+){0,}){0,}(-(#{ROLLING_RELEASES.join('|')})){0,1}).spec.erb/

        if match = Regexp.last_match
          return file.gsub('.spec.erb', '') if in_range?(version, match[1].to_s.split('-').drop(1)) || match[1].empty?
        end
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
