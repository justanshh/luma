# Luma

Luma is a GPL-2.0 Linux desktop music player for local audio and `.bex` content plugins.

## Install

Fedora RPM:

```bash
sudo dnf install ./fermata-0.1.0-1.fc45.x86_64.rpm
fermata
```

AppImage:

```bash
chmod +x Fermata-0.1.0-x86_64.AppImage
./Fermata-0.1.0-x86_64.AppImage
```

The RPM installs to `/usr/lib64/fermata` and exposes `/usr/bin/fermata`. Both package formats bundle the native player runtime.

## Build

```bash
./packaging/build_release.sh
```

Artifacts are written to `dist/`. The release also produces `fermata-0.1.0-source.tar.gz` for GPL source distribution.

## Features

- Local MP3, FLAC, OGG, and M4A libraries.
- Plugin-powered online search and playback.
- MPRIS media controls and a StatusNotifierItem tray.
- Resizable library/queue shell with persisted layout.
- Prefix search, queue editing, and bounded offline caching.
- Native folder and plugin pickers.

## License

GPL-2.0. See `LICENSE`.
