#!/usr/bin/env bash
# Build TraceDraw locally with host CPU auto-detection (e.g. Steam Deck or
# Steam Machine), while leaving CI builds on the portable baseline CPU.
# Usage: packaging/linux/build-local.sh [--flatpak]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
VERSION="$(sed -n 's/^version = "\(.*\)"$/\1/p' "$ROOT/Cargo.toml" | head -n 1)"
TARGET_DIR="${CARGO_TARGET_DIR:-$ROOT/target}"

WANT_FLATPAK=0
for arg in "$@"; do
  case "$arg" in
    --flatpak) WANT_FLATPAK=1 ;;
    -h|--help)
      echo "Usage: $0 [--flatpak]"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
  esac
done

detect_cpu_name() {
  if [ -r /proc/cpuinfo ]; then
    local model
    model="$(sed -n 's/^model name[[:space:]]*:[[:space:]]*//p' /proc/cpuinfo | head -n 1)"
    if [ -n "$model" ]; then
      echo "$model"
      return
    fi
  fi
  uname -m
}

# Only tune for the host CPU when building outside CI unless explicitly set.
if [ -z "${CI:-}" ] && [ -z "${GITHUB_ACTIONS:-}" ] && [ "${TRACEDRAW_TARGET_CPU:-}" != "generic" ]; then
  CPU="${TRACEDRAW_TARGET_CPU:-native}"
  RUSTFLAGS="${RUSTFLAGS:+$RUSTFLAGS }-C target-cpu=${CPU}"
  export RUSTFLAGS
  echo "Detected host CPU: $(detect_cpu_name) (building with -C target-cpu=${CPU})"
else
  echo "Using standard target CPU (CI or generic mode)"
fi

cd "$ROOT"
cargo build --release --locked -p tracedraw -p tracedraw-cli

if [ "$WANT_FLATPAK" -eq 1 ]; then
  ARCH="$(uname -m)"
  case "$ARCH" in
    aarch64|arm64) PKG_ARCH="arm64" ;;
    *) PKG_ARCH="x86_64" ;;
  esac
  mkdir -p "$ROOT/dist"
  TARBALL="$ROOT/dist/tracedraw-${VERSION}-linux-${PKG_ARCH}.tar.gz"
  tar -C "$TARGET_DIR/release" -czf "$TARBALL" tracedraw tracedraw-cli
  cp "$TARBALL" "$ROOT/packaging/linux/flatpak/tracedraw-linux-x86_64.tar.gz"
  MANIFEST="$ROOT/packaging/linux/flatpak/io.github.tracedraw.TraceDraw.yml"
  bash "$ROOT/packaging/linux/flatpak/manifest.sh" local "$VERSION" > "$MANIFEST"
  echo "Wrote tarball: $TARBALL"
  echo "Wrote Flatpak manifest: $MANIFEST"
  if command -v flatpak-builder >/dev/null 2>&1; then
    BUILD_DIR="$ROOT/dist/flatpak-build"
    REPO_DIR="$ROOT/dist/flatpak-repo"
    rm -rf "$BUILD_DIR" "$REPO_DIR"
    flatpak-builder --force-clean --repo="$REPO_DIR" "$BUILD_DIR" "$MANIFEST"
    BUNDLE="$ROOT/dist/tracedraw-${VERSION}-linux-${PKG_ARCH}-local.flatpak"
    flatpak build-bundle "$REPO_DIR" "$BUNDLE" io.github.tracedraw.TraceDraw
    echo "Built local Flatpak bundle: $BUNDLE"
  else
    echo "flatpak-builder not found; install flatpak-builder or bundle $TARGET_DIR/release binaries directly."
  fi
fi
