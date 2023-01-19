# ~/.bashrc: executed by bash(1) for non-login shells.
#
# This file contains basic bash options. Additional bash config will be
# included from the following locations:
#
# ~/.bashrc.after
# ~/.bashrc.d/*.rc
# ~/.bashrc.before

function source_if () {
    test -r "${1}" && source "${1}"
}

function first_of () {
    for item in "$@"; do
        test -e "$item" && echo -n "$item" && break
    done
}

function prepend_path () {
    local path="$1"
    if test -d "$path"; then
        if [[ $PATH != *$path* ]]; then
            export PATH="${path}:${PATH}"
        fi
    fi
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

PROJECT_DIR="$(first_of ~/Projects ~/projects)"
export PROJECT_DIR

if ! shopt -oq posix; then
    source_if "/etc/bash_completion"
    if which brew >/dev/null 2>&1; then
        source_if "$(brew --prefix)/etc/profile.d/bash_completion.sh"
    fi
fi

prepend_path /opt/homebrew/bin
prepend_path /opt/homebrew/sbin
prepend_path /usr/local/bin
prepend_path /usr/local/sbin

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
