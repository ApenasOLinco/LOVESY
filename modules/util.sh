#!/usr/bin/env bash
[[ $DEBUG == 'true' ]] && set -x

[[ -z $APP_ROOT ]] && {
	echo "This script can't be run directly."
	exit 1
}

function ltrim() {
	sed -E 's/^[[:space:]]+//'
}

function rtrim() {
	sed -E 's/[[:space:]]+$//'
}

function trim() {
	ltrim | rtrim
}

function showHelp() {
	source "$MODULES_DIR/help.sh"
	exit 0
}
