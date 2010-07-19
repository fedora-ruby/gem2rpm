Gem::Specification.new do |s|
  #### Basic information.

  s.name = "testing_gem"
  s.version = "1.0.0"
  s.summary = "Gem for use with gem2rpm's unit tests."
  s.description = <<-EOF
  This is for use with gem2rpm's unit tests.
  EOF

  #### Dependencies and requirements.

  s.files = ['lib/testing_gem.rb']
  s.required_rubygems_version = ">= 1.3.6"
  s.required_ruby_version = ">= 1.8.6"
  s.add_runtime_dependency('test_runtime', [">= 1.0.0"])
  s.add_development_dependency('test_development', [">=1.0.0"])

  #### Load-time details: library and application (you will need one or both).

  s.require_path = 'lib'                         # Use these for libraries.

  s.bindir = "bin"                               # Use these for applications.

  #### Documentation and testing.

  s.has_rdoc = false

  #### Author and project details.

  s.author = "Test"
  s.email = "test@example.com"
end
