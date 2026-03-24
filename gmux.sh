#!/bin/sh

set -o errexit
set -o nounset

LOCAL_FOLDER="$HOME/.local/share/gmux"
LAYOUT_FOLDER="$LOCAL_FOLDER/layouts"
TEMPLATE_FOLDER="$LOCAL_FOLDER/templates"
BASIC_TEMPLATE="$TEMPLATE_FOLDER/template"
LOG_FILE="$LOCAL_FOLDER/gmux.log"

# Write to log file
# 1: log level
# 2: log message
log_to_file() {
    echo "$(date +%T) $1: $2" >>"$LOG_FILE"
}

# Setup folders and files necessary for the script execution
setup() {
    if [ ! -d "$LOCAL_FOLDER" ]; then
        mkdir "$LOCAL_FOLDER"
    fi
    if [ ! -f "$LOG_FILE" ]; then
        touch "$LOG_FILE"
    fi
    if [ ! -d "$LAYOUT_FOLDER" ]; then
        log_to_file "INFO" "creating layout folder"
        mkdir "$LAYOUT_FOLDER"
    fi
    if [ ! -d "$TEMPLATE_FOLDER" ]; then
        log_to_file "INFO" "creating template folder"
        mkdir "$TEMPLATE_FOLDER"
    fi
    if [ ! -f "$BASIC_TEMPLATE" ]; then
        log_to_file "INFO" "creating template file"
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
    echo "-e, --edit        edit selected tmux layout"
    echo "-d, --delete      delete selected tmux layout"
    echo " "
    echo "logs available at $LOG_FILE"
}

# Prompt the user for the creation of a new layout. One the input is
# received a shell script is created and opened with the default text editor.
# The script is also made executable at the end.
create_new_layout() {
    read -p "Layout name: " NAME
    if [ -n "$NAME" ]; then
        FILE_NAME="$LAYOUT_FOLDER/$NAME.gmux.sh"
        log_to_file "INFO" "creating layout file $FILE_NAME"
        cp "$BASIC_TEMPLATE" "$FILE_NAME"
        echo "" >>"$FILE_NAME"
        echo "tmux new-session -s \"$NAME\" -d" >>"$FILE_NAME"
        echo "" >>"$FILE_NAME"
        echo "# Example of layout" >>"$FILE_NAME"
        echo "# tmux new-session -d -s \"Example\" -n \"Example-Window\" -c /path/to/workdir" >>"$FILE_NAME"
        echo "# tmux new-window -n \"Another-Window\" -t \"Test\"" >>"$FILE_NAME"
        echo "# tmux split-window -t \"Test:Another-Window\" -v -l 50% -c /path/to/workdir" >>"$FILE_NAME"
        $EDITOR "$FILE_NAME"
        log_to_file "INFO" "making $FILE_NAME executable"
        chmod +x "$FILE_NAME"
    fi
    clear
}

# Edit a selected layout file using the default editor of the user
edit_layout() {
    CHOICE=$(ls -1 "$LAYOUT_FOLDER" | sed -e 's/\.gmux.sh$//' | fzf --height 40% --style minimal --preview '' --reverse)
    if [ -n "$CHOICE" ]; then
        "$EDITOR" "$LAYOUT_FOLDER/$CHOICE.gmux.sh"
    fi
}

# Delete a selected layout file
delete_layout() {
    CHOICE=$(ls -1 $LAYOUT_FOLDER | sed -e 's/\.gmux.sh$//' | fzf --height 40% --style minimal --preview '' --reverse)
    if [ -n "$CHOICE" ]; then
        rm "$LAYOUT_FOLDER/$CHOICE.gmux.sh"
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
        exit 0
        ;;
    -d | --delete)
        delete_layout
        exit 0
        ;;
    *)
        echo "Invalid option $1. Use -h or --help to show available options"
        exit 1
        ;;
    esac
done

# Open existing layout and execute the script
CHOICE=$(ls -1 $LAYOUT_FOLDER | sed -e 's/\.gmux.sh$//' | fzf --height 40% --style minimal --preview '' --reverse)
if [ -n "$CHOICE" ]; then
    sh -c "$LAYOUT_FOLDER/$CHOICE.gmux.sh"
fi
