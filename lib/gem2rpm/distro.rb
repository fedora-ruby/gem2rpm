module Gem2Rpm
  class Distro
    FEDORA = :fedora
    OPENSUSE = :opensuse
    DEFAULT = :default

    def self.nature
      if !release_files.grep(/fedora/).empty?
        FEDORA
      elsif !release_files.grep(/SuSe/).empty?
        OPENSUSE
      else
        DEFAULT
      end
    end

    def self.release_files
      @@release_files ||= Dir.glob '/etc/*{_version,-release}*'
    end
  end
end

