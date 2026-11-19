# TraceDraw v0.49.0 - Steam Machine / SteamOS Flatpak (znver2 + PGO)

Prebuilt offline Flatpak bundle compiled for **AMD Zen 2 (`Steam Machine / Steam Deck`)** from `lukasz-sklad/tracedraw` (`v0.49.0`).

- **Application:** `io.github.tracedraw.TraceDraw`
- **Version:** `0.49.0`
- **Target CPU:** AMD Zen 2 (`-C target-cpu=znver2`, Fat LTO, 2-stage PGO)
- **Runtime & Permissions:** `org.freedesktop.Platform//26.08` (`GLIBC <= 2.39`, `--filesystem=home`, XDG portal media access, Flathub-validated AppStream metadata & screenshots)
- **File:** `TraceDraw-0.49.0-SteamMachine-znver2-PGO.flatpak` (32156064 bytes)
- **SHA-256:** `04f80730da15ef6d92b2dac4954d54abe3c37d1b392f11ae07675dac2bc203ff`

## Direct Download

- GitHub Release (`v0.49.0-steamdeck`): [github.com/lukasz-sklad/tracedraw/releases/tag/v0.49.0-steamdeck](https://github.com/lukasz-sklad/tracedraw/releases/tag/v0.49.0-steamdeck)
- Branch file: `https://github.com/lukasz-sklad/tracedraw/raw/refs/heads/steamdeck/TraceDraw-0.49.0-SteamMachine-znver2-PGO.flatpak`
- Fork main repo: [lukasz-sklad/tracedraw](https://github.com/lukasz-sklad/tracedraw)
- Clean upstream PR branch: [pr/flathub-wayland-linux-build](https://github.com/lukasz-sklad/tracedraw/tree/pr/flathub-wayland-linux-build)

## Installation

```bash
curl -LO https://github.com/lukasz-sklad/tracedraw/raw/refs/heads/steamdeck/TraceDraw-0.49.0-SteamMachine-znver2-PGO.flatpak
flatpak install --user -y ./TraceDraw-0.49.0-SteamMachine-znver2-PGO.flatpak
flatpak run --user io.github.tracedraw.TraceDraw
```
