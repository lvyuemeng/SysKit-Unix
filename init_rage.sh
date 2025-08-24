#!/bin/bash
set -euo pipefail

readonly RELEASE_VERSION="v0.11.1"
readonly BASE_URL="https://github.com/str4d/rage/releases/download/${RELEASE_VERSION}"

readonly INSTALL_DIR="/usr/local/bin"

# ---

if command -v rage &> /dev/null; then
	echo "rage is installed"
	exit 0
fi

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        FILE_NAME="rage-${RELEASE_VERSION}-x86_64-linux.tar.gz"
        ;;
    aarch64)
        FILE_NAME="rage-${RELEASE_VERSION}-aarch64-linux.tar.gz"
        ;;
    *)
        echo "Error: Unsupported architecture: $ARCH"
        echo "Error: Only supports x86_64 and aarch64."
        exit 1
        ;;
esac
	
DOWNLOAD_URL="${BASE_URL}/${FILE_NAME}"

echo "Downloading rage for ${ARCH} from ${DOWNLOAD_URL}..."
if curl -fsSL "${DOWNLOAD_URL}" | tar -xzf - -C /tmp; then
	if [ -f "tmp/rage" ]; then
		echo "Moving rage to ${INSTALL_DIR}"
		sudo mv /tmp/rage  "${INSTALL_DIR}/rage"
	else
		echo "Error: rage executable not found in the download archive"
		exit 1
	fi
else
	echo "Error: Failed to download or extract the archive"
	exit 1
fi