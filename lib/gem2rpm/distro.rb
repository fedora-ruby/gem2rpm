module Gem2Rpm
  class Distro
    FEDORA = :fedora
    PLD = :pld
    OPENSUSE = :opensuse
    DEFAULT = :default
    REDHAT = :redhat

    ROLLING_RELEASES = ['rawhide', 'factory', 'tumbleweed']

    OsRelease = Struct.new :os, :version

    # Returns struct with OS detected based on release files.
    #
    # Distro.os_release.os contains either one of supported distributions
    # (:fedora, :pld, :opensuse) or :default for unrecognized/unsupported
    # distributions.
    #
    # Distro.os_release.version contains version if it is possible to detect.
    def self.os_release
      @os_release ||= begin
        os_release = OsRelease.new DEFAULT

        grouped_release_files = release_files.group_by do |file|
          File.basename(file)[/os-release|fedora|redhat|SuSE|pld/] || 'unrecognized'
        end

        # Try os-release first.
        if (os_release_files = grouped_release_files['os-release'])
          content = File.open(os_release_files.first, Gem2Rpm::OPEN_MODE, &:read)

          begin
            os_release.os = content[/^ID=['"]?(.*?)['"]?$/, 1].to_sym
            os_release.version = content[/^VERSION_ID=['"]?(.*?)['"]?$/, 1]
          rescue
          end
        end

        # If os-release failed (it is empty or has not enough information),
        # try some other release files.
        if os_release.os == DEFAULT
          if (fedora_release_files = grouped_release_files['fedora'])
            os_release.os = FEDORA
            versions = []

            fedora_release_files.each do |file|
              /\d+/ =~ File.open(file, OPEN_MODE).readline
              versions << Regexp.last_match.to_s if Regexp.last_match
            end

            versions.uniq!

            os_release.version = versions.first if versions.length == 1
          elsif grouped_release_files['redhat']
            os_release.os = REDHAT
          elsif grouped_release_files['SuSE']
            os_release.os = OPENSUSE
          elsif grouped_release_files['pld']
            os_release.os = PLD
          end
        end

        os_release
      end
    end

    def self.nature
      template_by_os_version(os_release.os, os_release.version) || DEFAULT
    end

    # Provides list of release files found on the system.
    def self.release_files
      @release_files ||=
        Dir.glob('/etc/{os-release,*{_version,-release}}*').uniq.select { |e| File.file? e }
    end

    # Allows to override release files list.
    def self.release_files=(files)
      @os_release = nil
      @release_files = files
    end

    # Tries to find best suitable template for specified os and version.
    def self.template_by_os_version(os, version)
      os_templates = Template.list.grep(/#{os}.*\.spec\.erb/)
      os_templates.each do |file|
        # We want only distro RubyGems templates to get the right versions
        unless file =~ /^#{os}((-([0-9]+\.{0,1}[0-9]+){0,}){0,}(-(#{ROLLING_RELEASES.join('|')})){0,1}).spec.erb/
          # the above regexp matches "redhat-77-77.spec.erb" but not "redhat-7.spec.erb"
          # not quite sure how to fix that regexp without breaking something, so add another check here
          next unless file =~ /^#{os}-([0-9]+).spec.erb/
        end

        if (match = Regexp.last_match)
          return file.gsub('.spec.erb', '') if in_range?(version, match[1].to_s.split('-').drop(1)) || (version.to_s == match[1]) || match[1].empty?
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
          return true if ROLLING_RELEASES.include?(range[1]) || (version.to_s <= range[1].to_s)
        end
      end

      false
    end
  end
end
