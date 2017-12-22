#!/bin/bash

set -eu

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
RESET="$(tput sgr0)"

REPO_DIR="${HOME}/.files"

while [[ $# -gt 0 ]]; do
    option="$1"
    case $option in
        -e|--env)
            ENV="$2"
            shift
            ;;
        -r|--repo)
            REPO_DIR="$2"
            shift
            ;;
        -h|--help)
            echo "Install local config (AKA dot files)"
            echo "Usage: ./setup.sh [-r <repo>]"
            echo "    -r|--repo => Path to config directory [${REPO_DIR}]"
            exit
            ;;
        -*)
            echo "Unknown option: ${option}" 1>&2
            exit 1
            ;;
        *)
            echo "Unknown positional option: ${option}" 1>&2
            exit 1
            ;;
    esac
    shift
done

function save_original () {
    local file="$1"
    if [ -f "$file" ]; then
        local save_file="${file}.original"
        mv -i "$file" "$save_file"
        echo "${BLUE}Saved ${file} to ${save_file}${RESET}"
    fi
}

function link () {
    # Args:
    #     $1: path relative to file in dot files repo
    #     $2: target path (optional; default is $HOME/.$1 or $HOME/$1)
    local file="${REPO_DIR}/${1}"
    if [ ! -f "$file" ]; then
        echo "${RED}${file} does not exist in .files repo${RESET}" 1>&2
        return 1
    fi
    if [ "${2-}" ]; then
        local target="${2}"
    else
        local target="${HOME}/.${1}"
        if [ ! -d "$(dirname "$target")" ]; then
            local target="${HOME}/${1}"
        fi
    fi
    local target_dir="$(dirname "$target")"
    if [ ! -d "$target_dir" ]; then
        echo "${RED}Target directory \"${target_dir}\" does not exist${RESET}" 1>&2
        return 1
    fi
    if [ ! -L "$target" ]; then
        save_original "$target"
        ln -s "$file" "$target"
        echo "${GREEN}Linked ${target} to ${file}${RESET}"
    else
        echo "${YELLOW}${target} already points to $(readlink ${target})${RESET}" 1>&2
    fi
    return 0
}

if [ -e "$REPO_DIR" ]; then
    if [ ! -d "${REPO_DIR}/.git" ]; then
        echo "${RED}${REPO_DIR} exists but doesn't appear to be a git repo${RESET}"
        exit 1
    fi
else
    git clone https://github.com/wylee/dotfiles "$REPO_DIR"
fi

test -d ~/.bashrc.d || mkdir ~/.bashrc.d
test -d ~/.local || mkdir ~/.local
test -d ~/.local/bin || mkdir ~/.local/bin
test -d ~/.ssh || mkdir ~/.ssh

link bashrc
link checkoutmanager.cfg
link gitconfig
link gitignore
link hgignore
link hgrc
link ideavimrc
link inputrc
link live-backup.cfg
link profile
link pythonrc
link tmux.conf
link vimrc
link ssh/config

for file in "${REPO_DIR}/bashrc.d/"*.rc; do
    link "bashrc.d/$(basename "$file")"
done

for file in "${REPO_DIR}/local/bin/"*; do
    link "local/bin/$(basename "$file")"
done

if [ "$(uname -s)" = "Darwin" ]; then
    # Install Homebrew & some packages
    brew_path="/usr/local/bin/brew"
    if [ -f "$brew_path" ]; then
        echo "${YELLOW}Homebrew already installed at prefix $($brew_path --prefix)${RESET}"
    else
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        "$brew_path" doctor
        "$brew_path" install \
            bash-completion \
            git \
            mercurial \
            python \
            python3 \
            pyenv \
            ripgrep \
            vim
    fi
else
    echo "${YELLOW}Skipping Homebrew install since this doesn't appear to be a Mac${RESET}"
fi

function get_pip_installer () {
    if [ -f "get-pip.py" ]; then
        echo "${BLUE}Pip installer already downloaded"
    else
        echo -n "${BLUE}Getting pip installer... "
        curl -O https://bootstrap.pypa.io/get-pip.py
        echo "${GREEN}Done${RESET}"
    fi
}

function install_pip () {
    local version="${1}"
    local pip_exe="pip${version}"
    local python_exe="python${version}"
    if which "${pip_exe}" >/dev/null 2>&1; then
        echo "${YELLOW}${pip_exe} already installed at $(which "${pip_exe}")${RESET}"
    else
        get_pip_installer
        echo -n "${BLUE}Installing pip for Python ${version}... "
        "$python_exe" get-pip.py --upgrade --force-reinstall
        if which pyenv >/dev/null 2>&1; then
            pyenv rehash
        fi
        echo "${GREEN}Done${RESET}"
    fi
}

install_pip 2
install_pip 3
test -f get-pip.py && rm get-pip.py

echo -n "${BLUE}Installing/upgrading Python tools... "
pip2 install -U setuptools >/dev/null
pip2 install -U pip >/dev/null
pip3 install -U setuptools >/dev/null
pip3 install -U pip >/dev/null
pip3 install -U checkoutmanager >/dev/null
pip3 install -U virtualenv >/dev/null
echo "${GREEN}Done${RESET}"

mkdir -p "${HOME}/.vim/{autoload,bundle}"
echo -n "${BLUE}Checking out Pathogen plugins... "
checkoutmanager co vim-pathogen >/dev/null
echo "${GREEN}Done${RESET}"
pathogen_path="${HOME}/.vim/vim-pathogen/autoload/pathogen.vim"
pathogen_link="${HOME}/.vim/autoload/pathogen.vim"
if [ -L "$pathogen_link" ]; then
    echo "${YELLOW}pathogen.vim already linked to $(readlink $pathogen_link)${RESET}"
else
    echo -n "${BLUE}Linking ${pathogen_link} to ${pathogen_path}... "
    ln -s $pathogen_path $pathogen_link
    echo "${GREEN}Done${RESET}"
fi
