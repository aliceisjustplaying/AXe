#!/bin/bash
# Install axe to a specified location or default ~/.local/axe

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_PRODUCTS="${PROJECT_DIR}/build_products"

# Default installation directory
INSTALL_DIR="${1:-$HOME/.local/axe}"
BIN_DIR="${2:-$HOME/.local/bin}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔧 AXe Installer"
echo "================"
echo ""

# Check if build products exist
if [[ ! -f "${BUILD_PRODUCTS}/axe" ]]; then
    echo -e "${RED}Error: axe executable not found at ${BUILD_PRODUCTS}/axe${NC}"
    echo "Please run './scripts/build.sh' first or 'swift build -c release'"
    exit 1
fi

if [[ ! -d "${BUILD_PRODUCTS}/Frameworks" ]]; then
    echo -e "${RED}Error: Frameworks directory not found at ${BUILD_PRODUCTS}/Frameworks${NC}"
    echo "Please run './scripts/build.sh' first"
    exit 1
fi

echo "Installation directory: ${INSTALL_DIR}"
echo "Binary symlink: ${BIN_DIR}/axe"
echo ""

# Create directories
echo "📁 Creating directories..."
mkdir -p "${INSTALL_DIR}"
mkdir -p "${BIN_DIR}"

# Copy executable
echo "📦 Copying axe executable..."
cp "${BUILD_PRODUCTS}/axe" "${INSTALL_DIR}/axe"
chmod +x "${INSTALL_DIR}/axe"

# Copy frameworks
echo "📦 Copying Frameworks..."
rm -rf "${INSTALL_DIR}/Frameworks"
cp -R "${BUILD_PRODUCTS}/Frameworks" "${INSTALL_DIR}/Frameworks"

# Create symlink
echo "🔗 Creating symlink in ${BIN_DIR}..."
rm -f "${BIN_DIR}/axe"
ln -sf "${INSTALL_DIR}/axe" "${BIN_DIR}/axe"

# Verify installation
echo ""
echo "✅ Installation complete!"
echo ""
echo "Directory structure:"
echo "  ${INSTALL_DIR}/"
echo "  ├── axe"
echo "  └── Frameworks/"
ls "${INSTALL_DIR}/Frameworks" | sed 's/^/      ├── /'
echo ""
echo "Symlink:"
echo "  ${BIN_DIR}/axe -> ${INSTALL_DIR}/axe"
echo ""

# Test if it works
if command -v axe &> /dev/null; then
    echo "🎉 axe is now available in your PATH!"
    echo ""
    axe --version 2>/dev/null || echo "(run 'axe --help' to get started)"
else
    echo -e "${YELLOW}Note: ${BIN_DIR} may not be in your PATH${NC}"
    echo "Add this to your shell config (~/.zshrc or ~/.bashrc):"
    echo ""
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi
