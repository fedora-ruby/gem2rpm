# -*- ruby -*-
require 'rubygems'
require 'rubygems/package_task'
require 'rake/clean'
require 'rake/testtask'

# Determine the current version
PKG_NAME = "gem2rpm"
SPEC_FILE = "rubygem-gem2rpm.spec"

if `ruby -rubygems -Ilib ./bin/gem2rpm --version` =~ /\S+$/
  CURRENT_VERSION = $&
else
  CURRENT_VERSION = "0.0.0"
end

if ENV['REL']
  PKG_VERSION = ENV['REL']
else
  PKG_VERSION = CURRENT_VERSION
end

PKG_FILES = FileList[
  'bin/**/*',
  'lib/**/*',
  'templates/**/*',
  'LICENSE',
  'README.md'
]

spec = Gem::Specification.new do |s|

  #### Basic information.

  s.name = 'gem2rpm'
  s.version = PKG_VERSION
  s.summary = "Generate rpm specfiles from gems"
  s.description = <<-EOF
  Generate source rpms and rpm spec files from a Ruby Gem.
  The spec file tries to follow the gem as closely as possible
  EOF

  #### Dependencies and requirements.

  s.files = PKG_FILES.to_a

  #### Load-time details: library and application (you will need one or both).

  s.require_path = 'lib'                         # Use these for libraries.

  s.bindir = "bin"                               # Use these for applications.
  s.executables = ["gem2rpm"]

  #### Documentation and testing.

  s.extra_rdoc_files = ['AUTHORS', 'README.md', 'LICENSE']

  #### Author and project details.

  s.authors = ["David Lutterkort", "Vit Ondruch"]
  s.email = "gem2rpm-devel@rubyforge.org"
  s.homepage = "https://github.com/fedora-ruby/gem2rpm"
  s.license = "GPLv2+"

  #### Signing properties.

  if File.exist? "~/.ssh/voxik-private_key.pem"
    s.signing_key = File.expand_path("~/.ssh/voxik-private_key.pem")
    s.cert_chain = ["../../voxik-public_cert.pem"]
  end
end

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

CLEAN.include("pkg")

desc "Run tests by default"
task :default => [:test]

desc "Run unit tests"
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/test_*.rb']
end
