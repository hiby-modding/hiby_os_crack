#!/bin/bash

set -euo pipefail

# Script to repack modified firmware files into a new firmware UPT file for the R3Pro II

# Color Consts (just for decoration)
NC='\033[0m' # No Color
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

BOLD=$(tput bold)
NORMAL=$(tput sgr0)

PROJECT_ROOT=$(git rev-parse --show-toplevel)
UNPACKING_AND_REPACKING_DIR="${PROJECT_ROOT}/r3proii/unpacking_and_repacking"
SQUASHFS_ROOT="${UNPACKING_AND_REPACKING_DIR}/squashfs-root"
XIMAGE_PATH="${UNPACKING_AND_REPACKING_DIR}/xImage"
OUT_PKG="${UNPACKING_AND_REPACKING_DIR}/r3proii.upt"

# Pre-checks
if [[ ! -d "${SQUASHFS_ROOT}" ]] || [[ ! -f "${XIMAGE_PATH}" ]]; then
    echo -e "${Red}${BOLD}Error${NORMAL}: Missing squashfs-root/ directory or xImage file.${NC}"
    echo -e "${Yellow}Run unpack-helper.sh first and ensure xImage remains in the path.${NC}"
    exit 1
fi

# run the repacking script
"${PROJECT_ROOT}/scripts/repack.sh" -i "${SQUASHFS_ROOT}" -k "${XIMAGE_PATH}" -o "${OUT_PKG}"
