#!/usr/bin/env bash
set -euo pipefail

sudo pacman -S --needed --noconfirm libyaml git-delta difftastic

if [[ -f "$HOME/.netrc" ]]; then
  chmod 600 "$HOME/.netrc"
fi

mise settings ruby.compile=false

if ! mise which ruby >/dev/null 2>&1; then
  echo "Installing precompiled Ruby via mise..."
  mise install ruby
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec mise exec ruby -- "$SCRIPT_DIR/install.rb"
