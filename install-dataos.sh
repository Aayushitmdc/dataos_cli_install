#!/usr/bin/env bash
set -euo pipefail

# --- Ask for API Key (hidden input) ---
if [[ -z "${PRIME_APIKEY:-}" ]]; then
  read -r -s -p "🔑 Enter your PRIME_APIKEY: " PRIME_APIKEY < /dev/tty
  echo
fi
if [[ -z "$PRIME_APIKEY" ]]; then
  echo "❌ PRIME_APIKEY is required. Exiting."
  exit 1
fi

# --- Ask for CLI version ---
read -r -p "📦 Enter CLI version to install (e.g., 2.9): " CLI_VERSION < /dev/tty
if [[ -z "$CLI_VERSION" ]]; then
  echo "❌ CLI version is required. Exiting."
  exit 1
fi

# --- Detect OS/Arch ---
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$OS" in
  linux)   OS_NAME="linux" ;;
  darwin)  OS_NAME="darwin" ;;
  *) echo "❌ Unsupported OS: $OS"; exit 1 ;;
esac

case "$ARCH" in
  x86_64|amd64) ARCH_NAME="amd64" ;;
  arm64|aarch64) ARCH_NAME="arm64" ;;
  i386|i686) ARCH_NAME="386" ;;
  *) echo "❌ Unsupported Arch: $ARCH"; exit 1 ;;
esac

FILE_NAME="dataos-ctl-${OS_NAME}-${ARCH_NAME}.tar.gz"

# --- Download ---
echo "⬇️ Downloading DataOS CLI v${CLI_VERSION} for ${OS_NAME}-${ARCH_NAME}..."
curl --silent --location \
  --output "$FILE_NAME" \
  "https://prime.tmdata.io/plutus/api/v1/files/download?name=${FILE_NAME}&dir=cli-apps-${CLI_VERSION}&apikey=${PRIME_APIKEY}"

# --- Extract ---
tar -xvf "$FILE_NAME"

# --- Install ---
TARGET_DIR="$HOME/.dataos/bin"
mkdir -p "$TARGET_DIR"
mv ${OS_NAME}-${ARCH_NAME}/dataos-ctl "$TARGET_DIR/"

# --- Add to PATH ---
SHELL_RC="$HOME/.bashrc"
if [[ "$SHELL" == *"zsh" ]]; then SHELL_RC="$HOME/.zshrc"; fi
if ! grep -q "$TARGET_DIR" "$SHELL_RC"; then
  echo "export PATH=\$PATH:$TARGET_DIR" >> "$SHELL_RC"
  echo "✅ Added DataOS CLI to PATH in $SHELL_RC"
fi

echo "🎉 Installed DataOS CLI v${CLI_VERSION}"
echo "➡️ Run 'source $SHELL_RC' or restart your terminal."
echo "➡️ Verify with: dataos-ctl version"

