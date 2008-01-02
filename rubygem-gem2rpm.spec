# Generated from gem2rpm-0.5.2.gem by gem2rpm -*- rpm-spec -*-
%define ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%define gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%define gemname gem2rpm
%define geminstdir %{gemdir}/gems/%{gemname}-%{version}

Summary: Generate rpm specfiles from gems
Name: rubygem-%{gemname}
Version: @VERSION@
Release: 1%{?dist}
Group: Development/Languages
License: GPLv2+ or Ruby
URL: http://rubyforge.org/projects/gem2rpm/
Source0: %{gemname}-%{version}.gem
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: rubygems
BuildRequires: rubygems
BuildArch: noarch
Provides: rubygem(%{gemname}) = %{version}

%description 
Generate source rpms and rpm spec files from a Ruby Gem.  The spec file
tries to follow the gem as closely as possible, and be compliant with the
Fedora rubygem packaging guidelines


%prep

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{gemdir}
gem install --local --install-dir %{buildroot}%{gemdir} \
            --force %{SOURCE0}
mkdir -p %{buildroot}/%{_bindir}
mv %{buildroot}%{gemdir}/bin/* %{buildroot}/%{_bindir}
rmdir %{buildroot}%{gemdir}/bin
find %{buildroot}%{geminstdir}/bin -type f | xargs chmod a+x

%clean
rm -rf %{buildroot}

%files
%defattr(-, root, root, -)
%{_bindir}/gem2rpm
%dir %{geminstdir}
%doc %{geminstdir}/AUTHORS
%{geminstdir}/bin
%{geminstdir}/lib
%doc %{geminstdir}/README
%doc %{geminstdir}/LICENSE
%{geminstdir}/rubygem-gem2rpm.spec
%{gemdir}/cache/%{gemname}-%{version}.gem
%{gemdir}/specifications/%{gemname}-%{version}.gemspec


%changelog
* Mon Dec 10 2007 David Lutterkort (lutter at watzmann dot net) - 0.5.2-1
- Initial package
