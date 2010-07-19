require 'erb'
require 'socket'
require 'rubygems/format'

# Adapt to the differences between rubygems < 1.0.0 and after
# Once we can be reasonably certain that everybody has version >= 1.0.0
# all this logic should be killed
GEM_VERSION = Gem::Version.create(Gem::RubyGemsVersion)
HAS_REMOTE_INSTALLER = GEM_VERSION < Gem::Version.create("1.0.0")

if HAS_REMOTE_INSTALLER
  require 'rubygems/remote_installer'
end

# Extend String with a word_wrap method, which we use in the ERB template
# below.  Taken with modification from the word_wrap method in ActionPack.
# Text::Format does the smae thing better.
class String
  def word_wrap(line_width = 80)
    gsub(/\n/, "\n\n").gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip
  end
end

module Gem
  class Requirement
    def rpm_version_transform(version)
      if version == "> 0.0.0"
        version = ""
      elsif version =~ /^~> (.+)$/
        next_version = Gem::Version.create($1).bump.to_s

        version = ["=> #$1", "< #{next_version}"]
      end
      version
    end

    def to_rpm
      result = as_list
      return result.map { |version| rpm_version_transform(version) }.flatten
    end

  end
end

module Gem2Rpm
  Gem2Rpm::VERSION = "0.6.0"

  if HAS_REMOTE_INSTALLER
    def self.find_download_url(name, version)
      installer = Gem::RemoteInstaller.new
      dummy, download_path = installer.find_gem_to_install(name, "=#{version}")
      download_path += "/gems/" if download_path.to_s != ""
      return download_path
    end
  else
    def self.find_download_url(name, version)
      dep = Gem::Dependency.new(name, "=#{version}")
      fetcher = Gem::SpecFetcher.fetcher
      dummy, download_path = fetcher.find_matching(dep, false, false).first
      download_path += "gems/" if download_path.to_s != ""
      return download_path
    end
  end

  def Gem2Rpm.convert(fname, template=TEMPLATE, out=$stdout,
                      nongem=true, local=false)
    format = Gem::Format.from_file_by_path(fname)
    spec = format.spec
    spec.description ||= spec.summary
    download_path = ""
    unless local
      begin
        download_path = find_download_url(spec.name, spec.version)
      rescue Gem::Exception => e
        $stderr.puts "Warning: Could not retrieve full URL for #{spec.name}\nWarning: Edit the specfile and enter the full download URL as 'Source0' manually"
        $stderr.puts "#{e.inspect}"
      end
    end
    template = ERB.new(template, 0, '<>')
    out.puts template.result(binding)
  end

  # Returns the email address of the packager (i.e., the person running
  # gem2spec).  Taken from RPM macros if present, constructed from system
  # username and hostname otherwise.
  def Gem2Rpm.packager()
    packager = `rpm --eval '%{packager}'`.chomp
    if packager == '' or packager == '%{packager}'
      packager = "#{Etc::getpwnam(Etc::getlogin).gecos} <#{Etc::getlogin}@#{Socket::gethostname}>"
    end
    packager
  end

  TEMPLATE =
%q{# Generated from <%= File::basename(format.gem_path) %> by gem2rpm -*- rpm-spec -*-
%define ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%define gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%define gemname <%= spec.name %>
%define geminstdir %{gemdir}/gems/%{gemname}-%{version}

Summary: <%= spec.summary.gsub(/\.$/, "") %>
Name: rubygem-%{gemname}
Version: <%= spec.version %>
Release: 1%{?dist}
Group: Development/Languages
License: GPLv2+ or Ruby
<% if spec.homepage %>
URL: <%= spec.homepage %>
<% end %>
Source0: <%= download_path %>%{gemname}-%{version}.gem
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
<%
if spec.respond_to?(:required_rubygems_version)
  rubygems_requirement = spec.required_rubygems_version.to_rpm
else
  rubygems_requirement = ['']
end

for req in rubygems_requirement %>
Requires: rubygems <%= req %>
<% end %>
<% for d in spec.dependencies %>
<% if (!d.respond_to?(:type)) or (d.respond_to?(:type) and d.type == :runtime) %>
<%
if d.respond_to?(:requirement)
  requirement = d.requirement
else
  requirement = d.version_requirements
end
for req in requirement.to_rpm %>
Requires: rubygem(<%= d.name %>) <%= req  %>
<% end %>
<% end %>
<% end %>
<% for req in rubygems_requirement %>
BuildRequires: rubygems <%= req %>
<% end %>
<% if spec.extensions.empty? %>
BuildArch: noarch
<% end %>
Provides: rubygem(%{gemname}) = %{version}

%description
<%= spec.description.to_s.chomp.word_wrap(78) + "\n" %>

<% if nongem %>
%package -n ruby-%{gemname}
Summary: <%= spec.summary.gsub(/\.$/, "") %>
Group: Development/Languages
Requires: rubygem(%{gemname}) = %{version}
<% spec.files.select{ |f| spec.require_paths.include?(File::dirname(f)) }.reject { |f| f =~ /\.rb$/ }.collect { |f| File::basename(f) }.each do |p| %>
Provides: ruby(<%= p %>) = %{version}
<% end %>
%description -n ruby-%{gemname}
<%= spec.description.to_s.chomp.word_wrap(78) + "\n" %>
<% end # if nongem %>

%prep

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{gemdir}
<% rdoc_opt = spec.has_rdoc ? "--rdoc " : "" %>
gem install --local --install-dir %{buildroot}%{gemdir} \
            --force <%= rdoc_opt %>%{SOURCE0}
<% unless spec.executables.empty? %>
mkdir -p %{buildroot}/%{_bindir}
mv %{buildroot}%{gemdir}/bin/* %{buildroot}/%{_bindir}
rmdir %{buildroot}%{gemdir}/bin
find %{buildroot}%{geminstdir}/bin -type f | xargs chmod a+x
<% end %>
<% if nongem %>
mkdir -p %{buildroot}%{ruby_sitelib}
<% spec.files.select{ |f| spec.require_paths.include?(File::dirname(f)) }.each do |p| %>
ln -s %{gemdir}/gems/%{gemname}-%{version}/<%= p %> %{buildroot}%{ruby_sitelib}
<% end %>
<% end # if nongem %>

%clean
rm -rf %{buildroot}

%files
%defattr(-, root, root, -)
<% for f in spec.executables %>
%{_bindir}/<%= f %>
<% end %>
%{gemdir}/gems/%{gemname}-%{version}/
<% if spec.has_rdoc %>
%doc %{gemdir}/doc/%{gemname}-%{version}
<% end %>
<% for f in spec.extra_rdoc_files %>
%doc %{geminstdir}/<%= f %>
<% end %>
%{gemdir}/cache/%{gemname}-%{version}.gem
%{gemdir}/specifications/%{gemname}-%{version}.gemspec

<% if nongem %>
%files -n ruby-%{gemname}
%defattr(-, root, root, -)
%{ruby_sitelib}/*
<% end # if nongem %>

%changelog
* <%= Time.now.strftime("%a %b %d %Y") %> <%= packager %> - <%= spec.version %>-1
- Initial package
}
end

# Local Variables:
# ruby-indent-level: 2
# End:
