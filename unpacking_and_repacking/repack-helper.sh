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
UNPACKING_AND_REPACKING_DIR="${PROJECT_ROOT}/unpacking_and_repacking"
SQUASHFS_ROOT="${UNPACKING_AND_REPACKING_DIR}/squashfs-root"
XIMAGE_PATH="${UNPACKING_AND_REPACKING_DIR}/xImage"

FIRMWARE_DIR="${PROJECT_ROOT}/firmwares"

echo -e "${BOLD}########################"
echo -e "### SELECTING DEVICE ###"
echo -e "########################${NC}"
echo -e ""

# Find all device folders in the firmwares folder
mapfile -t DEVICE_DIRS < <(find "$FIRMWARE_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

declare -a ALL_DEVICES
index=1

echo -e "Devices"

for ((i=0; i<${#DEVICE_DIRS[@]}; i++)); do
    dir="${DEVICE_DIRS[$i]}"
    ALL_DEVICES[$index]="$dir"

    if [ $i -eq $((${#DEVICE_DIRS[@]}-1)) ]; then
        prefix="└──"
    else
        prefix="├──"
    fi

    echo -e "$prefix ${Yellow}$index)${NC} ${Cyan}$(basename "$dir")${NC}"
    ((index++))
done

echo -e

echo -e "${Yellow}${BOLD}Note: Device selection just defines the name of the output .upt file, nothing else. Make sure that the firmware you are repacking will work on the device you are targetting.${NC}"
while true; do
    read -rp "$(echo -e "Select device ${Yellow}${BOLD}[1-$((index-1))]${NORMAL}: ")" choice

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ -n "${ALL_DEVICES[$choice]:-}" ]; then
        DEVICE_DIR="${ALL_DEVICES[$choice]}"
        DEVICE="$(basename "$DEVICE_DIR")"
        break
    fi

    echo -e "Invalid selection."
done

echo -e

OUT_PKG="${UNPACKING_AND_REPACKING_DIR}/${DEVICE}.upt"

# Pre-checks
if [[ ! -d "${SQUASHFS_ROOT}" ]] || [[ ! -f "${XIMAGE_PATH}" ]]; then
    echo -e "${Red}${BOLD}Error${NORMAL}: Missing squashfs-root/ directory or xImage file.${NC}"
    echo -e "${Yellow}Run unpack-helper.sh first and ensure xImage remains in the path.${NC}"
    exit 1
fi

# run the repacking script
"${PROJECT_ROOT}/scripts/repack.sh" -i "${SQUASHFS_ROOT}" -k "${XIMAGE_PATH}" -o "${OUT_PKG}"
