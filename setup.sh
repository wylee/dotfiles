#!/bin/bash

REPO_DIR="${HOME}/.files"

function save_original () {
    local file="$1"
    if [ -f "$file" ]; then
        local save_file="${file}.original"
        mv -i "$file" "$save_file"
        echo "Saved $file to $save_file"
    fi
}

function link () {
    # Args:
    #     $1: relative path to file in dot files repo
    #     $2: target path (optional; default is $HOME/.$1 or
    #         $HOME/$1)
    local file="${REPO_DIR}/${1}"
    if [ ! -f "${file}" ]; then
        echo "${file} does not exist in .files repo" 1>&2
        return 1
    fi
    if [ "${2}" ]; then
        local target="${2}"
    else
        local target="${HOME}/.${1}"
        if [ ! -d "$(dirname ${target})" ]; then
            local target="${HOME}/${1}"
        fi
    fi
    local target_dir="$(dirname ${target})" 
    if [ ! -d "${target_dir}" ]; then
        echo "Target directory \"${target_dir}\" does not exist" 1>&2
        return 1
    fi
    if [ ! -L "$target" ]; then
        save_original $target
        ln -s $file $target
        echo "Linked $target to $file"
    else
        echo "$target already points to $(readlink $target)" 1>&2
    fi
    return 0
}

if [ -e "$REPO_DIR" ]; then
    if [ ! -d "${REPO_DIR}/.hg" ]; then
        echo "$REPO_DIR exists but doesn't appear to be an hg repo"
        exit 1
    fi
else
    hg clone https://bitbucket.org/wyatt/dotfiles $REPO_DIR
fi

link ackrc
link aliasrc
link bashrc
link checkoutmanager.cfg
link gitconfig
link gitignore
link hgignore
link hgrc
link ideavimrc
link live-backup.cfg
link profile
link vimrc
link ssh/config
link Library/LaunchAgents/gpg-agent.plist

mkdir -p ~/.vim/{autoload,bundle}
checkoutmanager co vim-pathogen
ln -s ~/.vim/vim-pathogen/autoload/pathogen.vim ~/.vim/autoload
