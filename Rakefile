# -*- ruby -*-
require 'rubygems'
require 'rake/gempackagetask'
require 'rake/clean'

# Determine the current version

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
  'rubygem-gem2rpm.spec'
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

#
# FIXME: This is horked and needs love; just a copy-paste from puppet
#
# desc "Create an RPM"
# task :rpm do
#   tarball = File.join(Dir.getwd, "pkg", "gem2rpm-#{PKG_VERSION}.tgz")
#   rpmname = 'rubygem-gem2rpm'
#   sourcedir = `rpm --define 'name #{rpmname}' --define 'version #{PKG_VERSION}' --eval '%_sourcedir'`.chomp
#   specdir = `rpm --define 'name #{rpmname}' --define 'version #{PKG_VERSION}' --eval '%_specdir'`.chomp
#     basedir = File.dirname(sourcedir)

#     if ! FileTest::exist?(sourcedir)
#         FileUtils.mkdir_p(sourcedir)
#     end
#     FileUtils.mkdir_p(basedir)

#     target = "#{sourcedir}/#{File::basename(tarball)}"

#     sh %{cp %s %s} % [tarball, target]
#     sh %{cp conf/redhat/puppet.spec %s/puppet.spec} % basedir

#     Dir.chdir(basedir) do
#         sh %{rpmbuild -ba puppet.spec}
#     end

#     sh %{mv %s/puppet.spec %s} % [basedir, specdir]
# end

