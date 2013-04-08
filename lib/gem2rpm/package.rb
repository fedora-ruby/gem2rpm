require 'rubygems/package'

module Gem2Rpm
  class Package
    # Return new instance of Gem::Package for RubyGems > 2, Gem::Format otherwise
    def self.new(gem)
      if Gem::Version.create(Gem::RubyGemsVersion) >= Gem::Version.create("2.0.0")
        Gem::Package.new(gem)
      else
        require 'rubygems/format'
        Gem::Format.from_file_by_path(gem)
      end
    end
  end
end