module Gem2Rpm
  class Template
    class TemplateError < Exception; end

    attr_accessor :filename

    def self.default_location
      @@location ||= File.join(File.dirname(__FILE__), '..', '..', 'templates')
    end

    def self.default_location=(location)
      @@location = location
    end

    def self.list
      @@list ||= Dir.chdir(default_location) do
        Dir.glob('*').sort
      end
    end

    def initialize(filename)
      if File.exists? filename
        @filename = filename
      else
        raise TemplateError, "Could not locate template #{filename}"
      end
    end

    def read
      File.read @filename, :mode => OPEN_MODE
    end
  end
end
