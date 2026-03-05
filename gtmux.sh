#!/bin/sh

while test $# -gt 0; do
	case "$1" in
	-h | --help)
		echo "Create, edit and use tmux layout"
		echo " "
		echo "options:"
		echo "-h, --help        show quick help"
		echo "-c, --create      create a new tmux layout"
		exit 0
		;;
	-c | --create)
		NAME=$(gum input --placeholder "Layout name")
		touch "$NAME"
		$EDITOR "$NAME"
		chmod +x "$NAME"
		exit 0
		;;
	*)
		echo "Invalid flag. Use -h or --help to show available options"
		break
		;;
	esac
done
