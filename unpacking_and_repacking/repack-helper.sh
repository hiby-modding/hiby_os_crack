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
OTA_COMPATIBILITY="${UNPACKING_AND_REPACKING_DIR}/ota_compatibility.in"

FIRMWARE_DIR="${PROJECT_ROOT}/firmwares"

# variable to track whether ota_compatibility.in file is available for repacking with
[[ -f "$OTA_COMPATIBILITY" ]] && ota_compatibility_present=true || ota_compatibility_present=false

repack_ota_compatibility=false  # variable for whether to repack ota_compatibility.in (set later by asking user)


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


# Include ota_compatibility.in
echo
if [ "$ota_compatibility_present" = true ]; then
	while true; do
		read -rp "$(echo -e "Include ota_compatibility.in file? ${Yellow}${BOLD}[Y/n]${NORMAL} ")" reply

		case "$reply" in
    ""|[yY]|[yY][eE][sS])  # empty answer is counted as yes
        repack_ota_compatibility=true
        break
        ;;
    [nN]|[nN][oO])
    	break
     	;;
    *)
    	echo -e "Invalid selection."
     	;;

		esac
	done
else
	echo -e ""
fi


# Pre-checks
if [[ ! -d "${SQUASHFS_ROOT}" ]] || [[ ! -f "${XIMAGE_PATH}" ]]; then
    echo -e "${Red}${BOLD}Error${NORMAL}: Missing squashfs-root/ directory or xImage file.${NC}"
    echo -e "${Yellow}Run unpack-helper.sh first and ensure xImage remains in the path.${NC}"
    exit 1
fi


# run the repacking script
repack_args=(-i "${SQUASHFS_ROOT}" -k "${XIMAGE_PATH}" -o "${OUT_PKG}")

if $ota_compatibility_present && $repack_ota_compatibility; then
    repack_args+=(-c "${OTA_COMPATIBILITY}")
fi

"${PROJECT_ROOT}/scripts/repack.sh" "${repack_args[@]}"

if ! $ota_compatibility_present; then
	echo -e ""
	echo -e "${Yellow}NOTE: No ${Cyan}ota_compatibility.in${Yellow} file found, so it was not included in the repacked firmware, this may mean the firmware will not be compatible with some players (such as a HiBy R1 that came with the v2.0 firmware).${NC}"
fi
