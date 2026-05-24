function post_family_tweaks__preset_configs() {
	display_alert "$BOARD" "applying preset configs for headless first-boot" "info"

	local preset_file="${SDCARD}/root/.not_logged_in_yet"

	# Apply network defaults (Ethernet DHCP, no WiFi)
	echo "PRESET_NET_CHANGE_DEFAULTS=1" > "${preset_file}"
	echo "PRESET_NET_ETHERNET_ENABLED=1" >> "${preset_file}"
	echo "PRESET_NET_WIFI_ENABLED=0" >> "${preset_file}"

	# Disable manual wifi connect prompt
	echo "PRESET_CONNECT_WIRELESS=n" >> "${preset_file}"

	# Skip language/locale prompt on first login
	echo "SET_LANG_BASED_ON_LOCATION=n" >> "${preset_file}"

	# Locale and timezone defaults
	echo "PRESET_LOCALE=en_US.UTF-8" >> "${preset_file}"
	echo "PRESET_TIMEZONE=Asia/Shanghai" >> "${preset_file}"

	# User account (optional: set password to disable forced change prompt)
	echo "PRESET_USER_NAME=mellow" >> "${preset_file}"
	echo "PRESET_USER_PASSWORD=mellow" >> "${preset_file}"
	echo "PRESET_DEFAULT_REALNAME=Mellow Fly" >> "${preset_file}"
	echo "PRESET_USER_SHELL=bash" >> "${preset_file}"

	# Root credentials
	echo "PRESET_ROOT_PASSWORD=mellow" >> "${preset_file}"

	display_alert "$BOARD" "preset firstrun config done" "info"
}
