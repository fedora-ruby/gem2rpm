# -*- ruby -*-
require 'rubygems'
require 'rake/gempackagetask'
require 'rake/clean'

# Determine the current version
PKG_NAME="gem2rpm"
SPEC_FILE="rubygem-gem2rpm.spec"

if `ruby -Ilib ./bin/gem2rpm --version` =~ /\S+$/
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
  'LICENSE',
  'README',
  SPEC_FILE
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
  s.default_executable = "gem2rpm"

  #### Documentation and testing.

  s.has_rdoc = false
  s.extra_rdoc_files = ['AUTHORS', 'README', 'LICENSE']

  #### Author and project details.

  s.author = "David Lutterkort"
  s.email = "gem2rpm-devel@rubyforge.org"
  s.homepage = "http://rubyforge.org/projects/gem2rpm/"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

CLEAN.include("pkg")

desc "Build (S)RPM for #{PKG_NAME}"
task :rpm => [ :package ] do |t|
    system("sed -e 's/@VERSION@/#{PKG_VERSION}/' #{SPEC_FILE} > pkg/#{SPEC_FILE}")
    Dir::chdir("pkg") do |dir|
        dir = File::expand_path(".")
        system("rpmbuild --define '_topdir #{dir}' --define '_sourcedir #{dir}' --define '_srcrpmdir #{dir}' --define '_rpmdir #{dir}' -ba #{SPEC_FILE} > rpmbuild.log 2>&1")
        if $? != 0
            raise "rpmbuild failed"
        end
    end
end
