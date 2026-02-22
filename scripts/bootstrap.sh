#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v stow >/dev/null 2>&1; then
  echo "stow is required. Install it first (e.g. brew install stow)." >&2
  exit 1
fi

stow -nv tmux wezterm nvim
printf "\nDry-run complete. If it looks good, run:\n  stow tmux wezterm nvim\n"
