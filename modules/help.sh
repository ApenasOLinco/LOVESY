#!/usr/bin/env bash
[[ $DEBUG == 'true' ]] && set -x

[[ -z $APP_ROOT ]] && {
	echo "This script can't be run directly."
	exit 1
}

#region TEXT FORMAT
BOLD=$'\033[1m'
ITALIC=$'\033[3m'
#endregion

#region FOREGROUND COLORS
GREEN=$'\033[92m'
BRIGHT_RED=$'\033[91m'
#endregion

#region OTHER ANSI
RESET=$'\033[0m'
INDENT='   '
#endregion

#region OUTPUT FORMATTING
NAME_COLUMN_WIDTH=30
DESCRIPTION_COLUMN_START=$((${#INDENT} + NAME_COLUMN_WIDTH))
MAX_DESCRIPTION_LENGTH=80
#endregion

function printOption() {
	#region Args
	local optionNames="$1"
	local optionDescription="$2"
	#endregion

	local wrappedDesc
	wrappedDesc=$(
		echo "$optionDescription" |
			fmt -w $MAX_DESCRIPTION_LENGTH
	)

	local first=true
	while IFS= read -r line; do
		if $first; then
			printf \
				"${INDENT}${BOLD}${BRIGHT_RED}%-${NAME_COLUMN_WIDTH}s${RESET}%s\n" \
				"$optionNames" "$line"

			first=false
			continue
		fi

		printf "%${DESCRIPTION_COLUMN_START}s%s\n" "" "$line"
	done <<<"$wrappedDesc"

	echo
}

echo "Usage: ${GREEN}$(basename "$0") ${BOLD}[OPTIONS]${RESET}"
cat <<EOF

Simple, opinionated wrapper script for yt-dlp with some customizability. Currently only supports videos and only outputs .mp4.

EOF

# General Options
echo "General Options:"

# Header
printf \
	"${INDENT}${GREEN}${BOLD}%-${NAME_COLUMN_WIDTH}s%-${MAX_DESCRIPTION_LENGTH}s${RESET}\n" \
	"NAME" "DESCRIPTION"

printOption "-q, --quality" "The value used for height (e.g., -q 420 for 420p or less). Defaults to $DEFAULT_QUALITY"
printOption "-i, --input-file" "Path to a file containing linefeed-separated urls to be downloaded. Defaults to $DEFAULT_INPUT_FILE_PATH"
printOption "-o, --output-folder" "The folder that the resulting files will be created. Defaults to $DEFAULT_OUTPUT_DIR"
printOption "-h, --help" "Display this help message and exit"
