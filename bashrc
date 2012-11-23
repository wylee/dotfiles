# ~/.bashrc: executed by bash(1) for non-login shells.

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

# Fancy pants prompt
GRAY='\[\e[1;30m\]'
GRAY_BG='\[\e[0;47m\]'
RESET_COLOR='\[\e[0;0m\]'
GOTO_POS="\[\033"
hg_info() {
    if [ "$PWD" != "$HOME" ]; then
        if [ -d "${PWD}/.hg" ]; then
            hg -R . branch 2>/dev/null | awk '{print " (hg:"$1")"}'
        fi
    fi
}
# DATE TIME
# USER@HOST
# PWD (HGINFO)
# HISTORYNUM PROMPT
PS1="\
${GRAY_BG}\d                                                              \t${N}
${GRAY}\
\u@\H ${GOTO_POS}[80G\]«
\w\$(hg_info) ${GOTO_POS}[80G\]«
!\!> ${RESET_COLOR}\
"
export PS1

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Don't add certain commands to BASH history.
# & = ignore duplicates
# [ ]* = ignore commands starting with a space
export HISTIGNORE="&:[ ]*:exit"

export EDITOR=vim

export PATH=$HOME/.local/bin:$PATH
