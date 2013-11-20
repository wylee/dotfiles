# ~/.bashrc: executed by bash(1) for non-login shells.

function source_if () {
    if [ -f "$1" ]; then
        source "$1"
    fi
}

source_if ~/.bashrc.before

function first_of () {
    for p in $@; do
        if [ -e "$p" ]; then
            echo "$p"
            return 0
        fi
    done
    return 1
}

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Don't put duplicate lines in the history.
HISTCONTROL=ignoredups:ignorespace
HISTSIZE=1000
HISTFILESIZE=2000

# Append to the history file; don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Make less more friendly for non-text input files; see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

source_if "/usr/local/etc/bash_completion.d/git-prompt.sh"

# Fancy pants prompt
RED='\[\e[0;31m\]'
GREEN='\[\e[0;32m\]'
BLUE='\[\e[0;34m\]'
CYAN='\[\e[0;36m\]'
YELLOW='\[\e[1;33m\]'
GREY='\[\e[1;30m\]'
RESET_COLOR='\[\e[0;0m\]'
GOTO_POS="\[\033"
vcs_info() {
    if [ "$PWD" != "$HOME" ]; then
        if [ -d "${PWD}/.hg" ]; then
            hg -R . branch 2>/dev/null | awk '{print " (hg:"$1")"}'
        elif [ -d "${PWD}/.git" ]; then
            __git_ps1
        fi
    fi
}
# DATE                                                                     TIME
# USER@HOST
# PWD (HGINFO)
# HISTORYNUM PROMPT
PS1="\
${GREY}\d${GOTO_POS}[73G\]\t${RESET_COLOR}
${RED}\u${YELLOW}@${GREEN}\H${GOTO_POS}[80G\]${GREY}«
${CYAN}\w\$(vcs_info)${GOTO_POS}[80G\]${GREY}«
${YELLOW}>${RESET_COLOR} \
"
export PS1

# Don't add certain commands to BASH history.
# & = ignore duplicates
# [ ]* = ignore commands starting with a space
# ? and ?? = ignore all 1 and 2 character commands
export HISTIGNORE="&:[ ]*:?:??"

export EDITOR=vim

set -o vi
bind -m vi-insert "\C-l":clear-screen

PROJECT_DIR="$(first_of ~/projects ~/Projects)"
export PROJECT_DIR

PATH="/usr/local/bin:${PATH}"
# Local scripts take priority over anything else
LOCAL_BIN="${HOME}/.local/bin"
if [ -d "$LOCAL_BIN" ]; then
    PATH="${LOCAL_BIN}:${PATH}"
fi
export PATH

if ! shopt -oq posix; then
    source_if "/etc/bash_completion"
    if [ -x /usr/local/bin/brew ]; then
        source_if "$(brew --prefix)/etc/bash_completion"
    fi
fi

source_if ~/.aliasrc
source_if ~/.bashrc.after
