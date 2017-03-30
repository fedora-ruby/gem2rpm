[![Build Status](https://travis-ci.org/fedora-ruby/gem2rpm.svg?branch=master)](https://travis-ci.org/fedora-ruby/gem2rpm)

# gem2rpm

gem2rpm converts RubyGems packages to RPM spec files.

## Installation

You can install gem2rpm as any other gem from RubyGems.org:

```
$ gem install gem2rpm
```

or download gem2rpm from Fedora repositories as RPM package:

```
# dnf install rubygem-gem2rpm
```

## Usage

Run `gem2rpm --help` to see all of the options.

At its simplest, download a gem (let's call it GEM) in its latest
version (e.g. 1.2.3):

```
$ gem fetch GEM
```

and run gem2rpm:

```
$ gem2rpm GEM-1.2.3.gem
```

You can also use the `--fetch` flag to fetch the (latest) gem before generating the spec file, achieving the same effect as running 'gem fetch GEM' plus 'gem2rpm GEM-1.2.3.gem':

```
$ gem2rpm --fetch GEM
```

This will print an rpm spec file based on the information contained in the gem's spec file. In general, it is necessary to edit the generated spec file because the gem is missing some important information that is customarily provided in rpm's, most notably the license and the changelog.


Rather than editing the generated specfile, edit the template from which
the specfile is generated. This will make it easier to update the RPM when a new version of the Gem becomes available.

To support this process, it is recommended to first save the default
template somewhere:

```
$ gem2rpm -T > rubygem-GEM.spec.template
```

Now you can edit the template and then run gem2rpm to generate the spec file using the edited template:

```
$ gem2rpm -t rubygem-GEM.spec.template GEM-1.2.3.gem > rubygem-GEM.spec
```

With this new template you can now build your RPM as usual and when a new version of the gem becomes available, you just edit the saved template and rerun gem2rpm over it.

To see all available templates that are shipped and can be directly used with gem2rpm run:

```
$ gem2rpm --templates
```

## Templates

The template is a standard ERB file that comes with several variables:

- `package` - the `Gem::Package` for the gem
- `spec` - the `Gem::Specification` for the gem (the same as `format.spec`)
- `config` - the `Gem2Rpm::Configuration` that can redefine default macros or rules used in `spec` template helpers
- `runtime_dependencies` - the `Gem2Rpm::RpmDependencyList` providing list of package runtime dependencies
- `development_dependencies` - the `Gem2Rpm::RpmDependencyList` providing list of package development dependencies
- `tests` - the `Gem2Rpm::TestSuite` providing list of test frameworks allowing their execution
- `files` - the `Gem2Rpm::RpmFileList` providing unfiltered list of files in package
- `main_files` - the `Gem2Rpm::RpmFileList` providing list of files suitable for main package
- `doc_files` - the `Gem2Rpm::RpmFileList` providing list of files suitable for -doc subpackage

The following variables still work, but are now deprecated:

- `format` - The `Gem::Format` for the gem. Please note that this is kept just for compatibility reasons, since RubyGems 2.0 removed this class.

### Template Configuration

To make the templates lighter and more complete, Gem2Rpm introduced in version 0.11.0 new configurable template variables such as `main_files` or `doc_files` that can be further configured via local `config` variable as follows:

```ruby
# Change macros for Vagrant packaging
config.macros[:instdir] = '%{vagrant_plugin_instdir}'
config.macros[:libdir] = '%{vagrant_plugin_libdir}'

# Change what files go to the -doc sub-package
config.rules[:doc] = [/\/?doc(\/.*)?/]

```

To see all the defaults that can be changed (from https://github.com/fedora-ruby/gem2rpm/blob/master/lib/gem2rpm/configuration.rb):

```ruby
$ irb -rgem2rpm
> Gem2Rpm::Configuration::DEFAULT_MACROS
> Gem2Rpm::Configuration::DEFAULT_RULES
```

## Conventions

A typical source RPM for a gem should consist of two files: the gem file
itself and the spec file.

The resulting RPMs should follow the naming convention 'rubygem-$GEM'
where GEM is the name of the packaged gem.

## Limitations

Because of the differences between the two packaging schemes, it is impossible to come up with a completely automated way of doing the conversion, but the spec files produced by this package should be good enough for most pure-ruby gems.

## See also

Fedora ruby and rubygem packaging guidelines:
-  http://fedoraproject.org/wiki/Packaging/Ruby

Project website
-  https://github.com/fedora-ruby/gem2rpm
