Gem::Specification.new do |s|
  #### Basic information.

  s.name = "vagrant_plugin"
  s.version = "1.0.0"
  s.summary = "Gem for use with gem2rpm's unit tests."
  s.homepage = "https://github.com/fedora-ruby/gem2rpm/tree/master/test/artifacts/vagrant_plugin"
  s.description = <<-EOF
  This is for use with gem2rpm's unit tests.
  EOF
  s.license = "MIT"

  #### Dependencies and requirements.

  s.files = ['lib/vagrant_plugin.rb', 'MIT', 'AUTHORS']
  s.required_rubygems_version = ">= 1.3.6"
  s.required_ruby_version = ">= 1.8.6"
  s.add_runtime_dependency('test_runtime', ["~> 1.0", ">= 1.0.0"])
  s.add_development_dependency('test_development', ["~> 1.0", ">=1.0.0"])

  #### Load-time details: library and application (you will need one or both).

  s.require_path = 'lib' # Use these for libraries.

  #### Documentation and testing.

  s.has_rdoc = false

  #### Author and project details.

  s.author = "Test"
  s.email = "test@example.com"
end
