Name:           fermata
Version:        0.1.0
Release:        1%{?dist}
Summary:        Luma - local and plugin-powered desktop music player

License:        GPL-2.0-only
URL:            https://github.com/HemantKArya/BloomeeTunes
Source0:        %{name}-%{version}.tar.gz
BuildArch:      x86_64
%global debug_package %{nil}
%global __os_install_post %{nil}
%global __check_files %{nil}

Requires:       gtk3
Requires:       libX11.so.6
Requires:       libXi.so.6

%description
Luma is a desktop music player for local files and .bex content plugins.

%prep
%setup -q

%build
:

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_bindir} %{buildroot}%{_libdir}/fermata %{buildroot}%{_datadir}/applications %{buildroot}%{_datadir}/icons/hicolor/256x256/apps %{buildroot}%{_datadir}/licenses/fermata
cp -a packaging/AppDir/. %{buildroot}%{_libdir}/fermata/
install -m 0755 packaging/fermata-launcher.sh %{buildroot}%{_bindir}/luma
ln -s luma %{buildroot}%{_bindir}/fermata
install -m 0644 packaging/fermata.desktop %{buildroot}%{_datadir}/applications/fermata.desktop
install -m 0644 packaging/icons/luma.png %{buildroot}%{_datadir}/icons/hicolor/256x256/apps/luma.png
install -m 0644 LICENSE %{buildroot}%{_datadir}/licenses/fermata/LICENSE

%post
update-desktop-database %{_datadir}/applications || :
gtk-update-icon-cache %{_datadir}/icons/hicolor || :

%postun
update-desktop-database %{_datadir}/applications || :
gtk-update-icon-cache %{_datadir}/icons/hicolor || :

%files
%{_bindir}/luma
%{_bindir}/fermata
%{_libdir}/fermata
%{_datadir}/applications/fermata.desktop
%{_datadir}/icons/hicolor/256x256/apps/luma.png
%{_datadir}/licenses/fermata/LICENSE

%changelog
* Tue Nov 24 2026 Fermata contributors <noreply@example.invalid> - 0.1.0-1
- Initial desktop release.
