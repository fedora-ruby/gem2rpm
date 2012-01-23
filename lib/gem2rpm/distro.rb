module Gem2Rpm
  class Distro
    FEDORA = :fedora
    OPENSUSE = :opensuse
    DEFAULT = :default

    def self.nature
      if !release_files.grep(/fedora/).empty?
        versions = []

        release_files.each do |file|
          /\d+/ =~ File.open(file).readline
          versions << Regexp.last_match.to_s.to_i if Regexp.last_match
        end

        versions.uniq!

        if versions.length == 1
          get_template_by_os_version(FEDORA, versions.first) || FEDORA
        else # no version or more versions (=> don't know what to do)
          FEDORA
        end
      elsif !release_files.grep(/SuSe/).empty?
        OPENSUSE
      else
        DEFAULT
      end
    end

    def self.release_files
      @@release_files ||= Dir.glob '/etc/*{_version,-release}*'
    end

    def self.get_template_by_os_version(os, version)
      Dir.new(Gem2Rpm::template_dir).each do |file|
        /#{os}-([\w-]+).spec.erb/ =~ file
        return file.gsub('.spec.erb', '') if Regexp.last_match and is_in_range?(version, Regexp.last_match[1].to_s.split('-'))
      end

      nil
    end

    def self.is_in_range?(version, range)
      return nil unless range

      if range.length == 1
        return true if range.first.to_i == version
      else # range: [xx, yy]
        if range[0].to_i <= version
          return true if range[1] == 'rawhide' or version <= range[1].to_i
        end
      end

      false
    end
  end
end

