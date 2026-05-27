# Preset-firstrun: fully headless first-boot (no wizard prompts).
#
# Override defaults by setting these variables before enabling the extension:
#   PRESET_ROOT_PWD="mellow"
#   PRESET_USER="mellow"
#   PRESET_USER_PWD="mellow"
#   PRESET_TIMEZONE="Asia/Shanghai"
#   PRESET_LOCALE="en_US.UTF-8"

function post_family_tweaks__preset_configs() {
	display_alert "$BOARD" "preset-firstrun: writing headless first-boot presets" "info"

	local root_pwd="${PRESET_ROOT_PWD:-mellow}"
	local user_name="${PRESET_USER:-mellow}"
	local user_pwd="${PRESET_USER_PWD:-mellow}"
	local timezone="${PRESET_TIMEZONE:-Asia/Shanghai}"
	local locale="${PRESET_LOCALE:-en_US.UTF-8}"
	local preset_file="${SDCARD}/root/.not_logged_in_yet"

	# Network: Ethernet DHCP, no WiFi by default
	echo "PRESET_NET_CHANGE_DEFAULTS=1" > "${preset_file}"
	echo "PRESET_NET_ETHERNET_ENABLED=1" >> "${preset_file}"
	echo "PRESET_NET_WIFI_ENABLED=0" >> "${preset_file}"

	# Skip manual wifi connect prompt
	echo "PRESET_CONNECT_WIRELESS=n" >> "${preset_file}"

	# Skip language/locale prompt on first login
	echo "SET_LANG_BASED_ON_LOCATION=n" >> "${preset_file}"

	# Locale and timezone
	echo "PRESET_LOCALE=${locale}" >> "${preset_file}"
	echo "PRESET_TIMEZONE=${timezone}" >> "${preset_file}"

	# User account preset (armbian-firstlogin reads these to skip prompts)
	echo "PRESET_USER_NAME=${user_name}" >> "${preset_file}"
	echo "PRESET_USER_PASSWORD=${user_pwd}" >> "${preset_file}"
	echo "PRESET_DEFAULT_REALNAME=Mellow Fly" >> "${preset_file}"
	echo "PRESET_USER_SHELL=bash" >> "${preset_file}"

	# Root credentials
	echo "PRESET_ROOT_PASSWORD=${root_pwd}" >> "${preset_file}"

	# Write timezone to /etc/timezone so systemd uses it immediately
	echo "${timezone}" > "${SDCARD}/etc/timezone"

	display_alert "$BOARD" "preset-firstrun done (root:${root_pwd} user:${user_name}:${user_pwd})" "info"
}
