# Generated from gem2rpm-0.4.1.gem by gem2rpm -*- rpm-spec -*-
%define gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%define gemname gem2rpm
%define geminstdir %{gemdir}/gems/%{gemname}-%{version}

Summary: Generate rpm specfiles from gems
Name: rubygem-%{gemname}

Version: 0.4.2
Release: 1%{?dist}
Group: Development/Languages
License: GPL
URL: http://people.redhat.com/dlutter/gem2rpm.html
Source0: %{gemname}-%{version}.gem
BuildRoot: %{_tmppath}/%{name}-%{version}-root-%(%{__id_u} -n)
Requires: rubygems
BuildRequires: rubygems
BuildArch: noarch
Provides: rubygem(gem2rpm) = %{version}

%description
Generate source rpms and rpm spec files from a Ruby Gem.  The spec file
tries to follow the gem as closely as possible

%prep

%build

%install
%{__rm} -rf %{buildroot}
mkdir -p %{buildroot}%{gemdir}
gem install --local --install-dir %{buildroot}%{gemdir} --force %{SOURCE0}
mkdir -p %{buildroot}/%{_bindir}
mv %{buildroot}%{gemdir}/bin/* %{buildroot}/%{_bindir}
rmdir %{buildroot}%{gemdir}/bin
find %{buildroot}%{geminstdir}/bin -type f | xargs chmod a+x

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root)
%{_bindir}/gem2rpm
%{gemdir}/gems/%{gemname}-%{version}/
%doc %{geminstdir}/README
%doc %{geminstdir}/LICENSE
%{gemdir}/cache/%{gemname}-%{version}.gem
%{gemdir}/specifications/%{gemname}-%{version}.gemspec

%changelog
* Tue Mar  6 2007 David Lutterkort <dlutter@redhat.com> - 0.4.2-1
- New version

* Fri Feb 23 2007 David Lutterkort <dlutter@redhat.com> - 0.4.1-1
- Initial (selfpackaged) version
