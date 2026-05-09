# Allwinner H3 quad core SoC WiFi 100M Ethernet
# UART0: PA4/PA5 (ttyS0)
# SPI0: PC0-PC3 + CS on PA19
# I2C2: PE12/PE13
# WiFi: rtl8189ftv on mmc1
# Ethernet: internal PHY at addr 1, mii mode
BOARD_NAME="FLY H3"
BOARD_VENDOR="mellow"
BOARDFAMILY="sun8i"
BOARD_MAINTAINER=""
BOOTCONFIG="orangepi_pc_defconfig"
SERIALCON="ttyS0"
DEFAULT_CONSOLE="serial"
KERNEL_TARGET="current,edge"
KERNEL_TEST_TARGET="current"
BOOT_FDT_FILE="sun8i-h3-fly-h3.dtb"
DEFAULT_OVERLAYS="usbhost2 usbhost3"
HAS_VIDEO_OUTPUT="no"
MODULES_CURRENT=""
MODULES_BLACKLIST=""

function post_family_tweaks_bsp__fly-h3() {
	local overlay_src="${SRC}/overlay/sun8i-h3"
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
