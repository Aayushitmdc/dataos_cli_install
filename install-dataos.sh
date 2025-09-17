#!/usr/bin/env bash
set -euo pipefail

APP_NAME="dataos-ctl"
TARGET_DIR="$HOME/.dataos/bin"
CONFIG_DIR="$HOME/.config/dataos"
CRED_FILE="$CONFIG_DIR/credentials"
RELEASE_URL="https://prime.tmdata.io/plutus/api/v1/files/download"

# --- Ask for CLI version ---
read -r -p "📦 Enter CLI version (e.g., 2.9): " CLI_VERSION
if [[ -z "$CLI_VERSION" ]]; then
  echo "❌ CLI version required"; exit 1
fi

# --- Detect architecture ---
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64) ARCH_NAME="linux-amd64" ;;
  arm64|aarch64) ARCH_NAME="linux-arm64" ;;
  i386|i686) ARCH_NAME="linux-386" ;;
  *) echo "❌ Unsupported arch: $ARCH"; exit 1 ;;
esac

FILE_NAME="${APP_NAME}-${ARCH_NAME}.tar.gz"

# --- Get API key ---
read -r -s -p "🔑 Enter PRIME_APIKEY: " PRIME_APIKEY
echo
if [[ -z "$PRIME_APIKEY" ]]; then
  echo "❌ PRIME_APIKEY required"; exit 1
fi

# --- Download ---
echo "⬇️ Downloading $APP_NAME v$CLI_VERSION..."
curl --fail --location \
  --header "Authorization: Bearer ${PRIME_APIKEY}" \
  --output "$FILE_NAME" \
  "${RELEASE_URL}?name=${FILE_NAME}&dir=cli-apps-${CLI_VERSION}"

# --- Extract & Install ---
mkdir -p "$TARGET_DIR"
tar -xzf "$FILE_NAME"
mv ${ARCH_NAME}/${APP_NAME} "$TARGET_DIR/"
chmod +x "$TARGET_DIR/$APP_NAME"

# --- PATH update ---
SHELL_RC="$HOME/.bashrc"
if [[ "$SHELL" == *"zsh" ]]; then SHELL_RC="$HOME/.zshrc"; fi
if ! grep -q "$TARGET_DIR" "$SHELL_RC"; then
  echo "export PATH=\$PATH:$TARGET_DIR" >> "$SHELL_RC"
  echo "✅ Added $TARGET_DIR to PATH in $SHELL_RC"
fi

echo "🎉 Installed $APP_NAME v${CLI_VERSION}"
echo "➡️ Run 'source $SHELL_RC' or restart terminal."
echo "➡️ Verify with: $APP_NAME version"
