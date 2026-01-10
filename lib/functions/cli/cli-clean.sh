#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-2.0
#
# Copyright (c) 2013-2026 Igor Pecovnik, igor@armbian.com
#
# This file is a part of the Armbian Build Framework
# https://github.com/armbian/build/

function cli_clean_pre_run() {
	# No need to require basic dependencies for cleaning
	declare -g ARMBIAN_COMMAND_REQUIRE_BASIC_DEPS="no"
}

function cli_clean_run() {
	display_alert "Starting cleanup process" "clean command" "info"

	# Initialize basic paths if not already set
	declare -g DEST="${SRC}/output"
	declare -g DEB_STORAGE="${DEST}/debs"

	# Parse CLEAN_LEVEL parameter if provided, otherwise default to "images"
	declare clean_target="${CLEAN_LEVEL:-images}"
	
	# If additional non-param arguments were provided, use them as clean targets
	if [[ ${#ARMBIAN_NON_PARAM_ARGS[@]} -gt 1 ]]; then
		# First arg is 'clean', rest are targets
		clean_target="${ARMBIAN_NON_PARAM_ARGS[1]}"
	fi

	case "${clean_target}" in
		all)
			display_alert "Cleaning all targets" "debs, cache, images, sources" "info"
			general_cleaning "alldebs"
			general_cleaning "cache"
			general_cleaning "images"
			general_cleaning "sources"
			;;
		debs | alldebs)
			display_alert "Cleaning" "all .deb packages" "info"
			general_cleaning "alldebs"
			;;
		cache)
			display_alert "Cleaning" "rootfs cache" "info"
			general_cleaning "cache"
			;;
		images)
			display_alert "Cleaning" "output images" "info"
			general_cleaning "images"
			;;
		sources)
			display_alert "Cleaning" "cached sources" "info"
			general_cleaning "sources"
			;;
		oldcache)
			display_alert "Cleaning" "old rootfs cache (keeping newest ${ROOTFS_CACHE_MAX:-8})" "info"
			general_cleaning "oldcache"
			;;
		*)
			display_alert "Available clean targets:" "all, debs, cache, images, sources, oldcache" "info"
			display_alert "Usage examples:" "./compile.sh clean [target]" "info"
			display_alert "  or:" "./compile.sh clean CLEAN_LEVEL=cache" "info"
			exit_with_error "Unknown clean target '${clean_target}'"
			;;
	esac

	display_alert "Cleanup completed successfully" "${clean_target}" "info"
}
