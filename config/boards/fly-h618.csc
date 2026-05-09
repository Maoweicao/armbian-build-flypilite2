# Allwinner H618 quad core SoC
BOARD_NAME="FLY H618"
BOARD_VENDOR="mellow"
BOARDFAMILY="sun50iw9"
BOARD_MAINTAINER=""
BOOTCONFIG="orangepi_zero3_defconfig"
BOOTBRANCH="tag:v2025.04"
BOOTPATCHDIR="v2025-sunxi"
BOOT_LOGO="desktop"
OVERLAY_PREFIX="sun50i-h618"
KERNEL_TARGET="current,edge"
KERNEL_TEST_TARGET="current"
FORCE_BOOTSCRIPT_UPDATE="yes"
BOOT_FDT_FILE="sun50i-h618-fly-h618.dtb"
SERIALCON="ttyS0"
HAS_VIDEO_OUTPUT="no"
DEFAULT_CONSOLE="serial"
MODULES_BLACKLIST="ac200"
DEFAULT_OVERLAYS="uart2-ph uart5-ph"

function family_tweaks_s__disable_networkd_wait_online__fly-h618() {
	# Mask networkd-wait-online to prevent boot hang on boards without Ethernet
	if [[ -f "${SDCARD}/lib/systemd/system/systemd-networkd-wait-online.service" ]]; then
		display_alert "${BOARD}" "Masking systemd-networkd-wait-online to prevent boot hang" "info"
		chroot "${SDCARD}" /bin/bash -c "systemctl mask systemd-networkd-wait-online.service >/dev/null 2>&1" || true
	fi
}

function post_family_tweaks_bsp__fly-h618() {
	local overlay_src="${SRC}/overlay/sun50i-h618"
	local overlay_dst="${destination}${OVERLAY_DIR:-/boot/dtb/allwinner/overlay}"
	local overlay_root="${overlay_dst%/overlay}"
	local base_dtb_src="${SRC}/config/kernel/${BOOT_FDT_FILE}"
	local base_dtb_dst="${overlay_root}/${BOOT_FDT_FILE}"

	if [[ -d "${overlay_src}" ]]; then
		display_alert "${BOARD}" "Installing board overlays into ${overlay_dst}" "info"
		mkdir -p "${overlay_dst}"
		local dtbo
		for dtbo in "${overlay_src}"/*.dtbo; do
			[[ -f "${dtbo}" ]] || continue
			run_host_command_logged install -m 644 "${dtbo}" "${overlay_dst}/"
		done
	else
		display_alert "${BOARD}" "Overlay source missing: ${overlay_src}" "warn"
	fi

	if [[ -f "${base_dtb_src}" ]]; then
		display_alert "${BOARD}" "Installing board DTB ${BOOT_FDT_FILE}" "info"
		mkdir -p "${overlay_root}"
		run_host_command_logged install -m 644 "${base_dtb_src}" "${base_dtb_dst}"
	else
		display_alert "${BOARD}" "Base DTB missing: ${base_dtb_src}" "warn"
	fi
}
