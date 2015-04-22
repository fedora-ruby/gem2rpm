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

    # Returns instance of Template class. If the 'name' parameter is specified
    # it tries to instantiate the template of specific name first. When
    # options[:gem_file] is specified, it can be taken into consideration
    # when looking for vagrant templates for example.
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

    # Create instance of Template class of specified template filename.
    # TemplateError is raised when the template file does not exists.
    def initialize(filename)
      if File.exists? filename
        @filename = filename
      else
        raise TemplateError, "Could not locate template #{filename}"
      end
    end

    # Read the content of the template file.
    def read
      @content ||= File.read @filename, :mode => OPEN_MODE
    end
  end
end
