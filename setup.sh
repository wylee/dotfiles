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
    local file="${REPO_DIR}/${1}"
    local target="${2-"${HOME}/.${1}"}"
    if [ ! -L "$target" ]; then
        save_original $target
        ln -s $file $target
        echo "Linked $target to $file"
    else
        echo "$target already points to $(readlink $target)"
    fi
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
link profile
link vimrc
link ssh/config

mkdir -p ~/.vim/{autoload,bundle}
checkoutmanager co vim-pathogen
ln -s ~/.vim/vim-pathogen/autoload/pathogen.vim ~/.vim/autoload
