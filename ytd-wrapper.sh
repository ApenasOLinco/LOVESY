#!/usr/bin/env bash
[[ $DEBUG == 'true' ]] && set -x

## ================
## Program Boostrap
## ================

# shellcheck disable=SC2155
export APP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC2155
export MODULES_DIR="$APP_ROOT/modules"
# shellcheck disable=SC1091
source "$MODULES_DIR/util.sh"

#region ARGUMENTS
export DEFAULT_QUALITY=1080
export DEFAULT_INPUT_FILE_PATH="$APP_ROOT/urls.txt"
export DEFAULT_OUTPUT_DIR="$APP_ROOT/downloaded/"
#endregion

function processArgs() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
		# Video Quality
		'-q' | '--quality')
			[[ $2 =~ ^[0-9]+$ ]] || {
				echo "Invalid value for -q | --quality: \"$2\" is not a number" >&2
				exit 1
			}
			quality=$2
			shift 2
			;;

		# Input File
		'-i' | '--input-file')
			[[ -f $2 ]] || {
				echo "Invalid value: \"$2\" isn't an existent file" >&2
				exit 1
			}
			inputFilePath=$2
			shift 2
			;;

		# Output Folder
		'-o' | '--output-folder')
			[[ -z "$2" ]] && { echo "Invalid value for output folder: no value passed" && exit 1; }
			outputDir="$2"
			[[ ! -d "$outputDir" ]] && { mkdir -p "$outputDir" && echo "Created $outputDir directory"; }
			shift 2
			;;

		# Usage Message
		'-h' | '--help') showHelp ;;

		# Sum BS
		*) echo "Not recognized: \"$1\". Use \"-h\" for usage help" && exit 1 ;;
		esac
	done
}

processArgs "$@"

get-download-urls() {
	local fileContent
	fileContent=$(cat "$1")

	local result
	result="$fileContent"

	# Respectively:
	# Remove full line comments (lines starting with #)
	# Remove end-of line comments (e.g. "this is my url # this is my comment")
	# Remove empty lines
	# And finally trim leading/trailing whitespace
	result=$(
		echo "$result" | sed \
			-e 's/^ *#.*//g' \
			-e 's/ \{1,\}#.*//g' |
			awk 'NF' |
			trim
	)

	echo "$result"
}

urls=$(get-download-urls "$inputFilePath")

for url in $urls; do
	yt-dlp \
		-f "bestvideo[height<=$quality]+bestaudio" \
		--merge-output-format mp4 \
		-o "./$outputDir/(Quality: $quality) %(uploader)s - %(title)s.%(ext)s" \
		"$url"
done
