#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
VERSION="0.1.0"
TOOLS="/run/media/justansh/DRIVER/fermata-packaging-tools"
APP_DIR="/run/media/justansh/DRIVER/fermata-AppDir"
DIST="/run/media/justansh/DRIVER/fermata-dist"
RPM_TOP="/run/media/justansh/DRIVER/fermata-rpmbuild"
export APPIMAGE_EXTRACT_AND_RUN=1
export PATH="/run/media/justansh/DRIVER/fermata-build-tools/bin:/run/media/justansh/DRIVER/flutter-sdk/bin:/run/media/justansh/DRIVER/fermata-build-tools/root/usr/bin:/run/media/justansh/DRIVER/fermata-build-tools/usr/bin:$PATH"
export PUB_CACHE="/run/media/justansh/DRIVER/flutter-pub-cache"
export CARGO_TARGET_DIR="/run/media/justansh/DRIVER/fermata-cargo-target"

mkdir -p "$DIST" "$RPM_TOP"
ln -sfn "$DIST" dist

rm -rf build/linux/x64/release
flutter build linux --release

rm -rf "$APP_DIR" "$RPM_TOP"
mkdir -p "$APP_DIR"
cp -a build/linux/x64/release/bundle/. "$APP_DIR/"
mkdir -p "$APP_DIR/usr/lib"
cp -a "$HOME/.local/lib64/fermata"/libmpv.so.2* "$APP_DIR/usr/lib/"
ln -sfn fermata "$APP_DIR/luma"

export LD_LIBRARY_PATH="$HOME/.local/lib64/fermata${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
"$TOOLS/linuxdeploy" \
  --appdir "$APP_DIR" \
  --executable "$APP_DIR/fermata" \
  --library "$HOME/.local/lib64/fermata/libmpv.so.2" \
  --desktop-file packaging/fermata.desktop \
  --icon-file packaging/icons/luma.png

if [ -f "$APP_DIR/usr/bin/fermata" ]; then
  cp "$APP_DIR/usr/bin/fermata" "$APP_DIR/fermata"
fi
if [ -d "$APP_DIR/usr/lib" ]; then
  cp -a "$APP_DIR/usr/lib/." "$APP_DIR/lib/"
fi
rm -rf "$APP_DIR/usr/lib" "$APP_DIR/usr/bin"
/run/media/justansh/DRIVER/fermata-build-tools/usr/bin/patchelf --set-rpath '$ORIGIN/lib' "$APP_DIR/fermata"
ln -sfn fermata "$APP_DIR/AppRun"

mkdir -p build/linux/x64/release/bundle/lib
cp -a "$APP_DIR/lib/." build/linux/x64/release/bundle/lib/

"$TOOLS/appimagetool" "$APP_DIR" "$DIST/Luma-${VERSION}-x86_64.AppImage"

mkdir -p "$RPM_TOP/SOURCES" "$RPM_TOP/SPECS" "$RPM_TOP/BUILD" "$RPM_TOP/BUILDROOT" "$RPM_TOP/RPMS" "$RPM_TOP/SRPMS"
tar --exclude=build --exclude=.dart_tool --exclude=dist --exclude=packaging/AppDir --exclude=packaging/rpmbuild --exclude='*.AppImage' --transform='s,^\.,fermata-0.1.0,' -czf "$DIST/fermata-${VERSION}-source.tar.gz" .
ln -sfn "$APP_DIR" packaging/AppDir
tar --exclude=build --exclude=.dart_tool --exclude=dist --exclude=packaging/rpmbuild --exclude='*.AppImage' --transform='s,^\.,fermata-0.1.0,' -czf "$RPM_TOP/SOURCES/fermata-${VERSION}.tar.gz" .
rm packaging/AppDir
rpmbuild -bb packaging/fermata.spec --define "_topdir $RPM_TOP" --define "__rpmuncompress /run/media/justansh/DRIVER/fermata-build-tools/usr/bin/rpmuncompress"
cp "$RPM_TOP/RPMS/x86_64/fermata-${VERSION}-1.fc45.x86_64.rpm" "$DIST/"
