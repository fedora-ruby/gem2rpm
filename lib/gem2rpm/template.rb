module Gem2Rpm
  module Template
    def self.location
      @@location ||= File.join(File.dirname(__FILE__), '..', '..', 'templates')
    end

    def self.list
      @@list ||= Dir.chdir(location) do
        Dir.glob('*').sort
      end
    end
  end
end
