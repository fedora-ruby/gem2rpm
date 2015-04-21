module Gem2Rpm
  module Template
    def self.default_location
      @@location ||= File.join(File.dirname(__FILE__), '..', '..', 'templates')
    end

    def self.list
      @@list ||= Dir.chdir(default_location) do
        Dir.glob('*').sort
      end
    end
  end
end
