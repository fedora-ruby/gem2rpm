module Gem2Rpm
  module Templates
    def self.location
      @@location ||= File.join(File.dirname(__FILE__), '..', '..', 'templates')
    end
  end
end
