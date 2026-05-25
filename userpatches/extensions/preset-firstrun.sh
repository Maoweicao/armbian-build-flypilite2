# Preset-firstrun: sets root/user passwords and network config during build
# so the board is fully usable without first-boot wizard.
#
# Override defaults by setting these variables before enabling the extension:
#   PRESET_ROOT_PWD="mellow"
#   PRESET_USER="mellow"
#   PRESET_USER_PWD="mellow"
#   PRESET_TIMEZONE="Asia/Shanghai"
#   PRESET_LOCALE="en_US.UTF-8"

function post_family_tweaks__preset_configs() {
	display_alert "$BOARD" "preset-firstrun: configuring root/user accounts in rootfs" "info"

	# --- defaults (set before calling) ---
	local root_pwd="${PRESET_ROOT_PWD:-mellow}"
	local user_name="${PRESET_USER:-mellow}"
	local user_pwd="${PRESET_USER_PWD:-mellow}"
	local timezone="${PRESET_TIMEZONE:-Asia/Shanghai}"
	local locale="${PRESET_LOCALE:-en_US.UTF-8}"

	# --- set root password directly in chroot ---
	display_alert "$BOARD" "setting root password" "info"
	chroot_sdcard "(" echo "'${root_pwd}'" ";" echo "'${root_pwd}'" ";" ")" "|" passwd root

	# --- create preset user ---
	display_alert "$BOARD" "creating user ${user_name}" "info"
	chroot_sdcard adduser --quiet --disabled-password --gecos "" "${user_name}" || true
	chroot_sdcard "(" echo "'${user_pwd}'" ";" echo "'${user_pwd}'" ";" ")" "|" passwd "${user_name}"
	chroot_sdcard usermod -aG sudo,netdev,audio,video,dialout,plugdev,input,tty,users "${user_name}" || true

	# --- timezone ---
	display_alert "$BOARD" "setting timezone to ${timezone}" "info"
	echo "${timezone}" > "${SDCARD}/etc/timezone"
	chroot_sdcard ln -sf "/usr/share/zoneinfo/${timezone}" /etc/localtime || true

	# --- locale ---
	display_alert "$BOARD" "setting locale to ${locale}" "info"
	sed -i "s/^# *${locale}/${locale}/" "${SDCARD}/etc/locale.gen" || true
	chroot_sdcard locale-gen "${locale}" || true
	echo "LANG=${locale}" > "${SDCARD}/etc/default/locale"

	# --- .not_logged_in_yet with network+locale only (passwords already applied) ---
	# armbian-firstlogin still runs network config when this file exists
	cat > "${SDCARD}/root/.not_logged_in_yet" <<- EOT
	PRESET_NET_CHANGE_DEFAULTS=1
	PRESET_NET_ETHERNET_ENABLED=1
	PRESET_NET_WIFI_ENABLED=0
	PRESET_CONNECT_WIRELESS=n
	SET_LANG_BASED_ON_LOCATION=n
	PRESET_LOCALE=${locale}
	PRESET_TIMEZONE=${timezone}
	PRESET_USER_SHELL=bash
	# Passwords already set during build — skip prompts
	PRESET_ROOT_PASSWORD=${root_pwd}
	PRESET_USER_NAME=${user_name}
	PRESET_USER_PASSWORD=${user_pwd}
	PRESET_DEFAULT_REALNAME=${user_name^}
	EOT

	display_alert "$BOARD" "preset-firstrun done: root:${root_pwd} user:${user_name}:${user_pwd}" "info"
}
