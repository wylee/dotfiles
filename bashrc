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
R='\[\e[1;31m\]'  # red
G='\[\e[1;32m\]'  # green
Y='\[\e[1;33m\]'  # yellow
B='\[\e[1;34m\]'  # blue
P='\[\e[1;35m\]'  # purple
C='\[\e[1;36m\]'  # cyan
N='\[\e[0m\]'     # reset color to default (N for neutral)
SAVE_POS="\[\033[s\]"
GOTO_SAVED_POS="\[\033[u\]"
GOTO_POS="\[\033"
hg_info() {
    if [ "$PWD" != "$HOME" ]; then
        if [ -d "${PWD}/.hg" ]; then
            hg -R . branch 2>/dev/null | awk '{print " (hg:"$1")"}'
        fi
    fi
}
# USER@HOST TIME
# PWD (HGINFO)
# HISTORYNUM PROMPT
PS1="\
${P}|${R}\u${Y}@${G}\H \
${SAVE_POS}${GOTO_POS}[72G\]${B}\t${P}|${GOTO_SAVED_POS}
\
${P}|${C}\w\$(hg_info) \
${SAVE_POS}${GOTO_POS}[80G\]${P}|${GOTO_SAVED_POS}
\
${P}|${Y}!\!>${N} \
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
