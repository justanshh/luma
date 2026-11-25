# Luma

Luma is a GPL-2.0 Linux desktop music player for local audio and `.bex` content plugins.

## Install

Fedora RPM:

```bash
sudo dnf install ./fermata-0.1.0-1.fc45.x86_64.rpm
luma
```

AppImage:

```bash
chmod +x Luma-0.1.0-x86_64.AppImage
./Luma-0.1.0-x86_64.AppImage
```

The RPM installs to `/usr/lib64/fermata` and exposes both `/usr/bin/luma` and
the legacy `/usr/bin/fermata` alias. Both package formats bundle the native
player runtime.

## Build

```bash
./packaging/build_release.sh
```

Artifacts are written to `dist/` (a symlink to the external release directory on
this machine). The release also produces `fermata-0.1.0-source.tar.gz` for GPL
source distribution.

## Features

- Local MP3, FLAC, OGG, and M4A libraries.
- Plugin-powered online search and playback.
- Home view with recently played tracks and suggestions.
- Playlists with create, reorder, pin, and play-all.
- Volume control, clear queue, and a settings screen.
- Automatic audio presets (Auto, Balanced, Bass, Vocal, Clear).
- Discord Rich Presence.
- MPRIS media controls and a StatusNotifierItem tray.
- Resizable library/queue shell with persisted layout.
- Prefix search, queue editing, and bounded offline caching.
- Native folder and plugin pickers.
- In-app updates from GitHub releases.

## License

GPL-2.0. See `LICENSE`.
