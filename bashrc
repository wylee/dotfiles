# ~/.bashrc: executed by bash(1) for non-login shells.
#
# This file contains basic bash options. Additional bash config will be
# included from the following locations:
#
# ~/.bashrc.after
# ~/.bashrc.d/*.rc
# ~/.bashrc.before

function source_if () {
    test -f "${1}" && source "${1}"
}

function first_of () {
    for item in "$@"; do
        test -e "$item" && echo -n "$item" && break
    done
}

source_if ~/.bashrc.before

# If not running interactively, don't do anything.
[ -z "$PS1" ] && return

# Prevent file overwrite on stdout redirection.
set -o noclobber

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Make less more friendly for non-text input files; see lesspipe(1).
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

set -o vi
bind -m vi-insert "\C-l":clear-screen
export EDITOR=vim

export PROJECT_DIR="$(first_of ~/Projects ~/projects)"

if ! shopt -oq posix; then
    source_if "/etc/bash_completion"
    which brew >/dev/null 2>&1 && source_if "$(brew --prefix)/etc/bash_completion"
fi

# Add /usr/local/bin if it's not already in $PATH.
echo "$PATH" | grep "/usr/local/bin" 1>/dev/null || export PATH="/usr/local/bin:${PATH}"

# Include additonal bash config from ~/.bashrc.d/*.rc.

BASHRC_DIR="${HOME}/.bashrc.d"
if [ -d "${BASHRC_DIR}" ]; then
    for f in $(find "${BASHRC_DIR}" -maxdepth 1 \( -type f -or -type l \) -name "*.rc"); do
        source "$f"
    done
fi

# The local bin directory takes precedence over everything else, no
# matter what.
LOCAL_BIN_DIR="${HOME}/.local/bin"
test -d "$LOCAL_BIN_DIR" && export PATH="${LOCAL_BIN_DIR}:${PATH}"

source_if ~/.bashrc.after
