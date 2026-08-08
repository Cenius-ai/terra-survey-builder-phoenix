#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Terra dependencies..."
cd "$(dirname "$0")"

# Install Hex + Rebar non-interactively
mix local.hex --force
mix local.rebar --force

# Get dependencies
mix deps.get

# Install Tailwind + Esbuild
mix tailwind.install --if-missing
mix esbuild.install --if-missing

# Download Manrope font files for self-hosting
echo "==> Downloading fonts..."
FONTS_DIR="priv/static/fonts"
mkdir -p "$FONTS_DIR"
for weight in 400 600 700; do
  FONT_URL="https://fonts.gstatic.com/s/manrope/v15/xn7gYHE41ni1AdIRggqxSvfedN62Zw.woff2"
  FONT_FILE="$FONTS_DIR/manrope-${weight}.woff2"
  if [ ! -f "$FONT_FILE" ]; then
    curl -sL "https://fonts.googleapis.com/css2?family=Manrope:wght@${weight}&display=swap" 2>/dev/null | \
      grep -oP 'url\(\K[^)]+' | head -1 | xargs curl -sL -o "$FONT_FILE" 2>/dev/null || true
  fi
done

# Build assets
mix assets.build

# Setup database (create, migrate, seed)
mix ecto.create 2>/dev/null || true
mix ecto.migrate
mix run priv/repo/seeds.exs

# Compile
mix compile

echo ""
echo "==> Terra installed successfully!"
echo "    Run: mix phx.server"
echo "    Open: http://localhost:4000"
