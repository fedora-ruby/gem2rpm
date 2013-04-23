module Gem2Rpm
  class Distro
    FEDORA = :fedora
    OPENSUSE = :opensuse
    DEFAULT = :default

    def self.nature
      if !release_files.grep(/fedora/).empty?
        versions = []

        release_files.each do |file|
          /\d+/ =~ File.open(file, "r:UTF-8").readline
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
      else
        DEFAULT
      end
    end

    def self.release_files
      @@release_files ||=
        Dir.glob('/etc/*{_version,-release}*').select {|e| File.file? e}
    end

    def self.template_by_os_version(os, version)
      Dir.new(Gem2Rpm::template_dir).each do |file|
        next if file =~ /^\./
        /#{os}-([\w-]+).spec.erb/ =~ file
        return file.gsub('.spec.erb', '') if Regexp.last_match and in_range?(version, Regexp.last_match[1].to_s.split('-'))
      end

      nil
    end

    def self.in_range?(version, range)
      return nil unless range

      if range.length == 1
        return true if range.first.to_s == version.to_s
      else # range: [xx, yy]
        if range[0].to_s <= version.to_s
          return true if range[1] == 'rawhide' or version.to_s <= range[1].to_s
        end
      end

      false
    end
  end
end

