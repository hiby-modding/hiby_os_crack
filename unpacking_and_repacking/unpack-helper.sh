#!/usr/bin/env bash

set -euo pipefail

# Script to extract the root filesystem from the original firmware

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

error() {
    echo -e "${Red}Error: $1${NC}" >&2
    exit 1
}

PROJECT_ROOT=$(git rev-parse --show-toplevel)
FIRMWARE_DIR="${PROJECT_ROOT}/firmwares"
UNPACKING_AND_REPACKING_DIR="${PROJECT_ROOT}/unpacking_and_repacking"
SQUASHFS_OUT_ROOT="${UNPACKING_AND_REPACKING_DIR}/squashfs-root"
XIMAGE_OUT_PATH="${UNPACKING_AND_REPACKING_DIR}/xImage"

echo -e "${BOLD}##########################"
echo -e "### SELECTING FIRMWARE ###"
echo -e "##########################${NC}"
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

# Find all .upt files in original and custom folders
DEVICE_FIRMWARE_DIR="${FIRMWARE_DIR}/${DEVICE}"
ORIGINAL_DIR="${DEVICE_FIRMWARE_DIR}/original"
CUSTOM_DIR="${DEVICE_FIRMWARE_DIR}/custom"

mapfile -t ORIGINAL_FW < <(find "$ORIGINAL_DIR" -maxdepth 1 -type f -name "*.upt" | sort)
mapfile -t CUSTOM_FW   < <(find "$CUSTOM_DIR"   -maxdepth 1 -type f -name "*.upt" | sort)

declare -a ALL_FW
index=1

echo -e "Original"

if [ ${#ORIGINAL_FW[@]} -eq 0 ]; then
    echo -e "└── ${Cyan}[No original firmwares present...] ${NC}${BOLD}(Place firmwares in ${ORIGINAL_DIR})${NC}"
else
	for ((i=0; i<${#ORIGINAL_FW[@]}; i++)); do
	    file="${ORIGINAL_FW[$i]}"
	    ALL_FW[$index]="$file"

	    if [ $i -eq $((${#ORIGINAL_FW[@]}-1)) ]; then
	        prefix="└──"
	    else
	        prefix="├──"
	    fi

	    echo -e "$prefix ${Yellow}$index)${NC} ${Cyan}$(basename "$file")${NC}"
	    ((index++))
	done
fi

echo -e
echo -e "Custom"

if [ ${#CUSTOM_FW[@]} -eq 0 ]; then
    echo -e "└── ${Cyan}[No custom firmwares present...] ${NC}${BOLD}(Place any custom firmwares in ${CUSTOM_DIR})${NC}"
else
    for ((i=0; i<${#CUSTOM_FW[@]}; i++)); do
        file="${CUSTOM_FW[$i]}"
        ALL_FW[$index]="$file"

        if [ $i -eq $((${#CUSTOM_FW[@]}-1)) ]; then
            prefix="└──"
        else
            prefix="├──"
        fi

        echo -e "$prefix ${Yellow}$index${NC}) ${Cyan}$(basename "$file")${NC}"
        ((index++))
    done
fi

echo -e

if [[ index == 1 ]]; then
	echo -e ${index}
	error "No firmwares available to unpack... Either add some firmwares for this device, or try another device."
fi

while true; do
    read -rp "$(echo -e "Select firmware ${Yellow}${BOLD}[1-$((index-1))]${NORMAL}: ")" choice

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ -n "${ALL_FW[$choice]}" ]; then
        FW_PATH="${ALL_FW[$choice]}"
        break
    fi

    echo -e "Invalid selection."
done


# run the unpacking script
"${PROJECT_ROOT}/scripts/unpack.sh" -i "${FW_PATH}" -k "${XIMAGE_OUT_PATH}" -o "${SQUASHFS_OUT_ROOT}"
