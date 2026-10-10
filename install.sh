#!/usr/bin/env bash
# Link each package into $HOME with GNU Stow.
# Usage: ./install.sh [package ...]   (default: every package directory)
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v stow >/dev/null 2>&1; then
  echo "stow is not installed. Run: sudo apt install stow" >&2
  exit 1
fi

packages=("$@")
if [ ${#packages[@]} -eq 0 ]; then
  for dir in */; do
    packages+=("${dir%/}")
  done
fi

for pkg in "${packages[@]}"; do
  echo "stow $pkg"
  stow --restow --target="$HOME" "$pkg"
done
