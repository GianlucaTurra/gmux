#!/bin/sh

set -o errexit
set -o nounset

LOCAL_FOLDER="$HOME/gmux"
LAYOUT_FOLDER="$LOCAL_FOLDER/layouts"
TEMPLATE_FOLDER="$LOCAL_FOLDER/templates"
BASIC_TEMPLATE="$TEMPLATE_FOLDER/template"
LOG_FILE="$LOCAL_FOLDER/gmux.log"

# Setup folders and files necessary for the script execution
setup() {
	if [ ! -d "$LOCAL_FOLDER" ]; then
		mkdir "$LOCAL_FOLDER"
	fi
	if [ ! -f "$LOG_FILE" ]; then
		touch "$LOG_FILE"
	fi
	if [ ! -d "$LAYOUT_FOLDER" ]; then
		echo "$(date +%T) INFO: creating layout folder" >>"$LOG_FILE"
		mkdir "$LAYOUT_FOLDER"
	fi
	if [ ! -d "$TEMPLATE_FOLDER" ]; then
		echo "$(date +%T) INFO: creating template folder" >>"$LOG_FILE"
		mkdir "$TEMPLATE_FOLDER"
	fi
	if [ ! -f "$BASIC_TEMPLATE" ]; then
		echo "$(date +%T) INFO: creating template file" >>"$LOG_FILE"
		touch "$BASIC_TEMPLATE"
		echo "#! /bin/sh" >"$BASIC_TEMPLATE"
		echo "set -o errexit" >>"$BASIC_TEMPLATE"
	fi
}

# Print basic help to use the script
print_help() {
	echo "Create, edit and use tmux layout"
	echo " "
	echo "options:"
	echo "-h, --help        show quick help"
	echo "-c, --create      create a new tmux layout"
	echo " "
	echo "logs available at $LOG_FILE"
}

# Use gum to prompt the user for the creation of a new layout. One the input is
# received a shell script is created and opened with the default text editor.
# The script is also made executable at the end.
create_new_layout() {
	NAME=$(gum input --placeholder "Layout name")
	if [ -n "$NAME" ]; then
		FILE_NAME="$LAYOUT_FOLDER/$NAME.gmux.sh"
		echo "$(date +%T) INFO: creating layout file $FILE_NAME from template" >>"$LOG_FILE"
		cp "$BASIC_TEMPLATE" "$FILE_NAME"
		echo "" >>"$FILE_NAME"
		echo "tmux new-session -s \"$NAME\" -d" >>"$FILE_NAME"
		$EDITOR "$FILE_NAME"
		echo "$(date +%T) TRACE: make $FILE_NAME executable" >>"$LOG_FILE"
		chmod +x "$FILE_NAME"
	fi
	clear
}

# Edit a selected layout file using the default editor of the user
edit_layout() {
	CHOICE=$(ls -1 $LAYOUT_FOLDER | sed -e 's/\.gmux.sh$//' | gum filter)
	if [ -n "$CHOICE" ]; then
		"$EDITOR" "$LAYOUT_FOLDER/$CHOICE.gmux.sh"
	fi
}

# -----------------------------------------------------------------------------
# ACTUAL FACTUAL PROGRAM
# -----------------------------------------------------------------------------

setup

# Controller of the given command flag (TODO: only one at the time?)
while test $# -gt 0; do
	case "$1" in
	-h | --help)
		print_help
		exit 0
		;;
	-c | --create)
		create_new_layout
		exit 0
		;;
	-e | --edit)
		edit_layout
		break
		;;
	*)
		echo "Invalid option $1. Use -h or --help to show available options"
		exit 1
		;;
	esac
done

# Open existing layout and execute the script
CHOICE=$(ls -1 $LAYOUT_FOLDER | sed -e 's/\.gmux.sh$//' | gum filter)
if [ -n "$CHOICE" ]; then
	sh -c "$LAYOUT_FOLDER/$CHOICE.gmux.sh"
fi
