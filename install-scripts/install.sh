#!/usr/bin/env bash
set -euo pipefail

sudo pacman -S --needed --noconfirm libyaml

if ! mise which ruby >/dev/null 2>&1; then
  echo "Installing Ruby via mise..."
  mise install ruby
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec mise exec ruby -- "$SCRIPT_DIR/install.rb"

