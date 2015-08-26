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
# yum install rubygem-gem2rpm
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

This will print an rpm spec file based on the information contained in the gem's spec file. In general, it is necessary to edit the generated spec file because the gem is missing some important information that is
customarily provided in rpm's, most notably the license and the changelog.


Rather than editing the generated specfile, edit the template from which
the specfile is generated. This will make it easier to update the RPM when a new version of the Gem becomes available.

To support this process, it is recommended to first save the default
template somewhere:

```
$ gem2rpm -T > rubygem-GEM.spec.template
```

Now you can edit the template and then run gem2rpm to generate the spec file using the edited template:

```
$ gem2rpm -t rubygem-GEM.spec.template > rubygem-GEM.spec
```

With this new template you can now build your RPM as usual and when a new version of the gem becomes available, you just edit the saved template and rerun gem2rpm over it.

To see all available templates that are shipped and can be directly used with gem2rpm run:

```
$ gem2rpm --templates
```

## Templates

The template is a standard ERB file that comes with three main variables:

- `package` - the `Gem::Package` for the gem
- `spec` - the `Gem::Specification` for the gem (the same as `format.spec`)
- `config` - the `Gem2Rpm::Configuration` that can redefine default macros or rules used in `spec` template helpers

The following variables still work, but are now deprecated:

- `format` - The `Gem::Format` for the gem. Please note that this is kept just for compatibility reasons, since RubyGems 2.0 removed this class.

### Template Configuration

To make the templates lighter and more complete, Gem2Rpm introduced in version 0.11.0 new configurable `spec` helpers such as `spec.main_file_entries` or `spec.doc_file_entries` that can be further configured via local `config` variable as follows:

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

A typical source RPM for a gem should consist of three files: the gem file
itself, the template for the spec file and the spec file. To ensure that
the template will be included in the source RPM, it must be listed as one
of the sources in the spec file.

The resulting RPMs should follow the naming convention 'rubygem-$GEM'
where GEM is the name of the packaged gem. The default template also makes
sure that the resulting package provides 'ruby($GEM)', according to general
packaging conventions for scripting languages.

## Docker image

You can also run gem2rpm with a docker container.

### Requirements

Install and configure [Docker](http://www.docker.com) for your platform.

### Build image

Run at project root:

```
docker build -t gem2rpm .
```

### Usage

To use gem2rpm using the docker image, run:

```
docker run -v `pwd`:/root/ gem2rpm [gem2rpm options and arguments]
```

* Share current local folder with `-v` in container's `/root/` directory.
* Output gem2rpm files with `-o` option in `/root/` directory.

## Limitations

Because of the differences between the two packaging schemes, it is impossible to come up with a completely automated way of doing the conversion, but the spec files produced by this package should be good enough for most pure-ruby gems.

## See also

Fedora ruby and rubygem packaging guidelines:
-  http://fedoraproject.org/wiki/Packaging/Ruby

Project website
-  https://github.com/fedora-ruby/gem2rpm
