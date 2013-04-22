require 'delegate'
require 'rubygems/package'
begin
  require 'rubygems/format'
rescue LoadError
end

module Gem2Rpm
  class Package < SimpleDelegator
    def initialize(gem)
      super(Gem::Package.new(gem)) rescue super(Gem::Format.from_file_by_path(gem))
    end
  end
end
