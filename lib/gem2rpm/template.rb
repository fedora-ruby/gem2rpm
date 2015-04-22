module Gem2Rpm
  class Template
    class TemplateError < Exception; end

    attr_accessor :filename

    def self.default_location
      @@location ||= File.join(File.dirname(__FILE__), '..', '..', 'templates')
    end

    def self.default_location=(location)
      @@location = location
      @@list = nil
    end

    def self.list
      @@list ||= Dir.chdir(default_location) do
        Dir.glob('*').sort
      end
    end

    def self.find(name = nil, options = {})
      if name.nil?
        case options[:gem_file]
        when /^vagrant(-|_).*/
          Gem2Rpm::VAGRANT_PLUGIN_TEMPLATE
        else
          Gem2Rpm::RUBYGEM_TEMPLATE
        end
      else
        begin
	  if File.exists?(name)
            Gem2Rpm::Template.new(name)
          else
            Gem2Rpm::Template.new(File.join(Gem2Rpm::Template::default_location, name + '.spec.erb'))
          end
        rescue TemplateError
          raise TemplateError, "Could not locate template #{name}"
        end
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
