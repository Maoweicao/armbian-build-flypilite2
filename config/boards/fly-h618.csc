# Allwinner H618 quad core 1GB RAM SoC AIC8800D80 WiFi/BT RMII Ethernet eMMC
# UART0: PH0/PH1 (ttyS0) - console
# UART1: PG6/PG7 (ttyS1)
# I2C0: PI5/PI6 - GT911 touch controller
# I2C3: PA10/PA11 - AC200 MFD for EPHY cal + clock
# SPI0: PC0-PC4 (cut pins)
# SPI1: PH5-PH9, PI7 - TFT display, touch
# MMC0: SD card, cd PF6
# MMC1: SDIO WiFi/BT (AIC8800D80), non-removable
# MMC2: eMMC 8-bit (non-removable)
# EMAC1: RMII, AC200 Internal EPHY @ addr 1
# USB OTG: peripheral mode
# PMIC: AXP313A on r_i2c addr 0x36
# AC200: PWM5 2MHz clock out, EPHY calibration via SID
# HDMI: enabled
BOARD_NAME="FLY H618"
BOARD_VENDOR="mellow"
BOARDFAMILY="sun50iw9"
BOARD_MAINTAINER=""
BOOTCONFIG="orangepi_zero3_defconfig"
BOOTBRANCH="tag:v2025.04"
BOOTPATCHDIR="v2025-sunxi"
BOOT_LOGO="desktop"
OVERLAY_PREFIX="sun50i-h618"
KERNEL_TARGET="legacy,current,edge"
KERNEL_TEST_TARGET="current"
FORCE_BOOTSCRIPT_UPDATE="yes"
BOOT_FDT_FILE="sun50i-h618-fly-h618.dtb"
SERIALCON="ttyS0"
HAS_VIDEO_OUTPUT="yes"
DEFAULT_CONSOLE="serial"
MODULES_BLACKLIST=""

AIC8800_TYPE="sdio"
enable_extension "radxa-aic8800"

function post_family_tweaks_bsp__fly-h618() {
	local overlay_src="${SRC}/overlay/sun50i-h618"
	local overlay_dst="${destination}${OVERLAY_DIR:-/boot/dtb/allwinner/overlay}"

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

	# The boot script looks for ${overlay_prefix}-fixup.scr (sun50i-h618-fixup.scr),
	# but the kernel DTB package only ships sun50i-h616-fixup.scr because H618 reuses
	# the H616 overlay namespace in the kernel tree. Create a symlink so the boot
	# script can find and apply the DT fixup (critical for USB/PHY/peripheral DT patches).
	display_alert "${BOARD}" "Creating sun50i-h618-fixup.scr -> sun50i-h616-fixup.scr symlink" "info"
	mkdir -p "${overlay_dst}"
	ln -sf sun50i-h616-fixup.scr "${overlay_dst}/sun50i-h618-fixup.scr"
}
