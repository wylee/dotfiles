#!/bin/bash

set -eu -o pipefail
shopt -s failglob

function create_color () {
    tput "$@" 2>/dev/null || echo ""
}

RED="$(create_color setaf 1)"
GREEN="$(create_color setaf 2)"
YELLOW="$(create_color setaf 3)"
BLUE="$(create_color setaf 4)"
RESET="$(create_color sgr0)"

REPO_DIR="${HOME}/.files"
BREW="yes"
NPM="yes"
PYTHON="yes"
INSTALL_PYTHON_VERSIONS="yes"
VIM_PLUGINS="yes"

BREW_PACKAGES=(
    bash-completion
    bitwarden-cli
    borgbackup
    exiftool
    fish
    git
    hugo
    node
    pass
    pwgen
    pyenv
    ripgrep
    shellcheck
    vim
)

BREW_CASKS=(
    authy
    bitwarden
    dropbox
    element
    firefox
    firefox-developer-edition
    iterm2
    jetbrains-toolbox
    signal
    sourcetree
    visual-studio-code
)

PYTHON_VERSIONS=(
    3.9.2
    3.8.8
    3.7.10
    3.6.13
)

PYTHON_VERSIONS_FILE="${HOME}/.python-version"

PYTHON_PACKAGES=(
    bpython
    checkoutmanager
    'poetry<1.1'
    totp
    twine
)

while [[ $# -gt 0 ]]; do
    option="$1"
    case $option in
        -r|--repo)
            REPO_DIR="$2"
            shift
            ;;
        --no-brew)
            BREW="no"
            ;;
        --no-npm)
            NPM="no"
            ;;
        --no-python)
            PYTHON="no"
            ;;
        --no-python-versions)
            INSTALL_PYTHON_VERSIONS="no"
            ;;
        --no-vim-plugins)
            VIM_PLUGINS="no"
            ;;
        -h|--help)
            echo "Install local config (AKA dot files)"
            echo "Usage: ./setup.sh [-r <repo>]"
            echo "    -r|--repo => Path to config directory [${REPO_DIR}]"
            echo "    --no-brew => Skip installation of Homebrew and packages"
            echo "    --no-npm => Skip npm update"
            echo "    --no-python => Skip all Python-related setup"
            echo "    --no-python-versions => Skip installation of Python versions"
            echo "    --no-vim-plugins => Skip installation of Vim plugins"
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
    #     $1: Source path relative to root of dot files repo.
    #
    #         Example: bashrc.d/alias.rc
    #
    #     $2: Target path. This rarely needs to be specified. It will be
    #         set to $HOME/.$1 by default; if `dirname $HOME/.$1` isn't
    #         an existing directory, the defaut target path will be set
    #         to $HOME/$1 instead.
    #
    #         Example of default: $HOME/.bashrc.d/alias.rc
    #
    # NOTE: The parent directory of the target *must* exist before calling
    #       this function.

    local source
    local target

    source="${REPO_DIR}/${1}"

    if [ ! -f "$source" ]; then
        echo "${RED}${source} does not exist in .files repo${RESET}" 1>&2
        return 1
    fi

    if [ "${2-}" ]; then
        target="${2}"
    else
        target="${HOME}/.${1}"
        if [ ! -d "$(dirname "$target")" ]; then
            target="${HOME}/${1}"
        fi
    fi

    if [ ! -L "$target" ]; then
        save_original "$target"
        ln -s "$source" "$target"
        echo "${GREEN}Linked ${target} to ${source}${RESET}"
    else
        echo "${YELLOW}${target} already points to $(readlink "${target}")${RESET}" 1>&2
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

if [ "$BREW" = "no" ]; then
    echo "${YELLOW}Skipping Homebrew installation and setup${RESET}"
elif [ "$(uname -s)" = "Darwin" ]; then
    # Install Homebrew & some packages
    brew_path="/usr/local/bin/brew"

    if [ -f "$brew_path" ]; then
        echo -n "${YELLOW}Homebrew already installed at prefix $($brew_path --prefix); "
        echo "upgrading...${RESET}"
        "$brew_path" update
        "$brew_path" upgrade --formula
        "$brew_path" upgrade --cask
    else
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    echo "${BLUE}Installing Homebrew packages...${RESET}"

    installed_formulas="$(brew list --formula)"

    for package in "${BREW_PACKAGES[@]}"; do
        if grep -Eq "\b$package\b" <<< "$installed_formulas"; then
            echo "Skipping package ${package} (already installed)"
        else
            "$brew_path" install "$package"
        fi
    done

    echo "${BLUE}Installing applications (casks) via Homebrew...${RESET}"

    installed_casks="$(brew list --cask)"

    for package in "${BREW_CASKS[@]}"; do
        if grep -Eq "\b$package\b" <<< "$installed_casks"; then
            echo "Skipping cask ${package} (already installed)"
        else
            "$brew_path" install --cask "$package"
        fi
    done

    if [ "$NPM" = "no" ]; then
        echo "${YELLOW}Skipping npm installation/update${RESET}"
    else
        echo -n "${BLUE}Installing/updating npm... ${RESET}"
        npm --force --global install npm &>/dev/null
        echo "${GREEN}npm setup complete${RESET}"
    fi

    fish_path="/usr/local/bin/fish"
    if grep $fish_path /etc/shells >/dev/null; then
        echo "${YELLOW}${fish_path} already in /etc/shells${RESET}"
    else
        echo "${BLUE}Adding fish to /etc/shells...${RESET}"
        echo $fish_path | sudo tee -a /etc/shells
    fi
    echo "${BLUE}To make fish the default shell, run: chsh -s $fish_path${RESET}"

    echo "${BLUE}Running 'brew cleanup'...${RESET}"
    "$brew_path" cleanup

    echo "${BLUE}Running 'brew autoremove'...${RESET}"
    "$brew_path" autoremove

    echo "${GREEN}Brew setup complete${RESET}"
else
    echo "${YELLOW}Skipping Homebrew install since this doesn't appear to be a Mac${RESET}"
fi

test -d ~/.bashrc.d || mkdir ~/.bashrc.d
test -d ~/.config || mkdir ~/.config
test -d ~/.config/fish || mkdir ~/.config/fish
test -d ~/.config/fish/functions || mkdir ~/.config/fish/functions
test -d ~/.emacs.d || mkdir ~/.emacs.d
test -d ~/.local || mkdir ~/.local
test -d ~/.local/bin || mkdir ~/.local/bin
test -d ~/.ssh || mkdir ~/.ssh
test -d ~/Projects || mkdir ~/Projects

link bashrc
link checkoutmanager.cfg
link emacs.d/init.el
link editorconfig
link gitconfig
link gitignore
link hgignore
link hgrc
link ideavimrc
link inputrc
link live-backup.cfg
link npmrc
link profile
link pythonrc
link vimrc
link ssh/config
link 'Library/Application Support/pypoetry/config.toml'

for file in "${REPO_DIR}/bashrc.d/"*.rc; do
    link "bashrc.d/$(basename "$file")"
done

for file in "${REPO_DIR}/config/fish/"*.fish; do
    link "config/fish/$(basename "$file")"
done

for file in "${REPO_DIR}/config/fish/functions/"*.fish; do
    link "config/fish/functions/$(basename "$file")"
done

link "config/fish/functions/additional-blackhole-hosts"

for file in "${REPO_DIR}/local/bin/"*; do
    link "local/bin/$(basename "$file")"
done

for file in "${REPO_DIR}/local/borg/exclude."*; do
    link "local/borg/$(basename "$file")"
done

for file in "${REPO_DIR}/local/borg/backup."*; do
    link "local/borg/$(basename "$file")" "${HOME}/.local/bin/$(basename "$file")"
done

if [ "$PYTHON" = "no" ]; then
    echo "${YELLOW}Skipping Python installation ${RESET}"
else
    main_python_version="python${PYTHON_VERSIONS[0]:0:3}"

    if [ "${INSTALL_PYTHON_VERSIONS}" = "yes" ]; then
        python_versions_string=$(printf "%s\n" "${PYTHON_VERSIONS[@]}")
        pyenv_versions=$(pyenv versions --bare)

        if test -f "${PYTHON_VERSIONS_FILE}"; then
            rm "${PYTHON_VERSIONS_FILE}"
            touch "${PYTHON_VERSIONS_FILE}"
            echo "${RED}Recreated ${PYTHON_VERSIONS_FILE}${RESET} (currently empty)"
        fi

        # For each installed pyenv version:
        #
        #   - If the version is in the current install list, do nothing
        #   - If the version isn't in the current install list, uninstall it
        for pyenv_version in $pyenv_versions; do
            if grep -Eq "^${pyenv_version}$" <<< "$python_versions_string"; then
                echo "${BLUE}Not uninstalling Python ${pyenv_version} (in current install list)"
            else
                echo "${YELLOW}Installed Python ${pyenv_version} not in current install list ${RESET}"
                read -r -p "${YELLOW}Uninstall Python ${pyenv_version}? [yes/no] ${RESET}" answer
                if [ "$answer" = "yes" ]; then
                    echo "${YELLOW}Uninstalling Python ${pyenv_version}... ${RESET}"
                    pyenv uninstall -f "$pyenv_version"
                    echo "${GREEN}Done${RESET}"
                fi
            fi
        done

        # For each Python version in the current install list:
        #
        #   - If the version is already installed, do nothing
        #   - If the version isn't already installed, install it
        for version in "${PYTHON_VERSIONS[@]}"; do
            if grep -Eq "^${version}$" <<< "$pyenv_versions"; then
                echo "${YELLOW}Python ${version} already installed${RESET}"
                echo "${version}" >>"${PYTHON_VERSIONS_FILE}"
                echo "${BLUE}Added ${version} to ${PYTHON_VERSIONS_FILE}"
            else
                read -r -p "${YELLOW}Install Python ${version}? [y/N] ${RESET}" answer
                case "$answer" in
                    y|Y|yes|YES)
                        echo "${BLUE}Installing Python ${version}... ${RESET}"
                        PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install "$version"
                        echo "${GREEN}Done${RESET}"
                        echo "${version}" >>"${PYTHON_VERSIONS_FILE}"
                        echo "${BLUE}Added ${version} to ${PYTHON_VERSIONS_FILE}"
                        ;;
                    *)
                        echo "${RED}Skipping installation of Python ${version}... ${RESET}"
                        ;;
                esac
            fi
        done

        eval "$(pyenv init -)"
    fi

    while read -r version; do
        echo -n "${BLUE}Upgrading pip for Python ${version}... ${RESET}"
        "python${version:0:3}" -m pip install --upgrade --upgrade-strategy eager pip >/dev/null
        echo "${GREEN}Done${RESET}"
    done <"${PYTHON_VERSIONS_FILE}"

    echo -n "${BLUE}Installing/upgrading pipx... ${RESET}"
    $main_python_version -m pip install --user --upgrade --upgrade-strategy eager pipx >/dev/null
    echo "${GREEN}Done${RESET}"

    echo "${BLUE}Installing/upgrading Python tools... ${RESET}"
    for package in "${PYTHON_PACKAGES[@]}"; do
        echo -n "${BLUE}Installing/upgrading ${package}... ${RESET}"
        $main_python_version -m pipx install \
            --force "${package}" \
            '--pip-args=--upgrade --upgrade-strategy eager' \
            >/dev/null
    done
    echo "${GREEN}Python setup complete${RESET}"
fi

if [ "$VIM_PLUGINS" = "no" ]; then
    echo "${YELLOW}Skipping Vim plugin installation${RESET}"
else
    mkdir -p "${HOME}/.vim/"{autoload,bundle}
    echo -n "${BLUE}Checking out Pathogen plugins... "
    checkoutmanager co vim-pathogen >/dev/null
    checkoutmanager up vim-pathogen >/dev/null
    echo "${GREEN}Done${RESET}"
    pathogen_path="${HOME}/.vim/vim-pathogen/autoload/pathogen.vim"
    pathogen_link="${HOME}/.vim/autoload/pathogen.vim"
    if [ -L "$pathogen_link" ]; then
        echo "${YELLOW}pathogen.vim already linked to $(readlink "$pathogen_link")${RESET}"
    else
        echo -n "${BLUE}Linking ${pathogen_link} to ${pathogen_path}... "
        ln -s "$pathogen_path" "$pathogen_link"
        echo "${GREEN}Done${RESET}"
    fi
fi

echo "${GREEN}Setup complete${RESET}"
