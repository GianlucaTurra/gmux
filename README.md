# GMUX

A simple CLI tool to create and manage tmux layouts as shell scripts.

## Dependencies

The only dependency of gmux is [gum](https://github.com/charmbracelet/gum).  
I'm lazy so refer to their docs to install it.

Ok, ok here's how you install it with linux brew:

```sh
brew install gum
```

## Installation

Clone this repo (I'm sure you know how) and run:

```sh
sudo cp ./gmux.sh /usr/bin/gmux
```

Or create and alias... Or call directly the script idk.

There you go.

## How to use the thingy

Here's a list of the available way to use `gmux`:

- `gmux`: show available layouts and run the selected one as a script
- `gmux -c` or `gmux --create`: create a new layout and open the freshly
  created script in your $EDITOR
- `gmux -e` or `gmux --edit`: show available layouts and open the selected in
  your $EDITOR for edit
- `gmux -h` or `gmux --edit`: call for help

Layouts are saved in `$HOME/gmux/layouts/` with the `.gmux.sh` extension.  
How you define a session is up to you and your imagination.  
A log file is written in `$HOME/gmux/`.
