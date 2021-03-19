#!/bin/bash

set -eu -o pipefail
shopt -s failglob

function create_color () {
    tput "$@" 2>/dev/null || echo ""
}

function colorize () {
    local type="$1"
    local message
    if [ "$type" = "default" ]; then
        message="$2"
    elif [ "$type" = "info" ]; then
        message="${BLUE}${2}${RESET}"
    elif [ "$type" = "success" ]; then
        message="${GREEN}${2}${RESET}"
    elif [ "$type" = "warning" ]; then
        message="${YELLOW}${2}${RESET}"
    elif [ "$type" = "error" ]; then
        message="${RED}${2}${RESET}"
    else
        message="$2"
    fi
    echo -n "$message"
}

function say () {
    local args
    local type
    local message
    if [ "$1" = "-n" ]; then
        args="-n"
        shift
    fi
    type="$1"
    message="${2-""}"
    if [ "$message" = "" ]; then
        message="$type"
        type="default"
    fi
    message=$(colorize "$type" "$message")
    if [ "$type" = "warning" -o "$type" = "error" ]; then
        echo $args "$message" 1>&2
    else
        echo $args "$message"
    fi
}

RED="$(create_color setaf 1)"
GREEN="$(create_color setaf 2)"
BLUE="$(create_color setaf 4)"
YELLOW="$(create_color setaf 3)"
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
    editorconfig
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
            say "Install local config (AKA dot files)"
            say ""
            say "Usage: ./setup.sh [-r <repo>]"
            say "    -r|--repo => Path to config directory [${REPO_DIR}]"
            say "    --no-brew => Skip installation of Homebrew and packages"
            say "    --no-npm => Skip npm update"
            say "    --no-python => Skip all Python-related setup"
            say "    --no-python-versions => Skip installation of Python versions"
            say "    --no-vim-plugins => Skip installation of Vim plugins"
            exit
            ;;
        -*)
            say error "Unknown option: ${option}"
            exit 1
            ;;
        *)
            say error "Unknown positional option: ${option}"
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
        say info "Saved ${file} to ${save_file}"
    fi
}

function create_dir () {
    # Create the specified directory if it doesn't already exist
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        say info "Created directory: ${1}"
    fi
}

function link_many () {
    # Link multiple sources at once
    for source in "$@"; do
        link "$source"
    done
}

function link_many_with_target () {
    # Link multiple sources at once into the same target directory
    local target
    sources=("$@")
    target="${!#}"
    unset "sources[$(( $# - 1 ))]"
    for source in "${sources[@]}"; do
        link "$source" "$target"
    done
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
        say error "${source} does not exist in .files repo"
        return 1
    fi

    if [ "${2-}" ]; then
        target="$2"
    else
        target="${HOME}/.${1}"
        if [ ! -d "$(dirname "$target")" ]; then
            target="${HOME}/${1}"
        fi
    fi

    if [ -d "$target" ]; then
        target="${target%%/}/$(basename "$source")"
    fi

    if [ ! -L "$target" ]; then
        save_original "$target"
        ln -s "$source" "$target"
        say success "Linked ${target} to ${source}"
    else
        say warning "${target} already points to $(readlink "${target}")"
    fi

    return 0
}

if [ -e "$REPO_DIR" ]; then
    if [ ! -d "${REPO_DIR}/.git" ]; then
        say error "${REPO_DIR} exists but doesn't appear to be a git repo"
        exit 1
    fi
else
    git clone https://github.com/wylee/dotfiles "$REPO_DIR"
fi

if [ "$BREW" = "no" ]; then
    say warning "Skipping Homebrew installation and setup"
elif [ "$(uname -s)" = "Darwin" ]; then
    # Install Homebrew & some packages
    brew_path="/usr/local/bin/brew"

    if [ -f "$brew_path" ]; then
        say warning "Homebrew already installed at prefix $($brew_path --prefix)"
        say info "Updating Homebrew..."
        "$brew_path" update
        say info "Upgrading Homebrew packages..."
        "$brew_path" upgrade --formula
        say info "Upgrading Homebrew apps (AKA casks)..."
        "$brew_path" upgrade --cask
    else
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    say info "Installing Homebrew packages..."

    installed_formulas="$(brew list --formula)"

    for package in "${BREW_PACKAGES[@]}"; do
        if grep -Eq "\b$package\b" <<< "$installed_formulas"; then
            say "Skipping package ${package} (already installed)"
        else
            "$brew_path" install "$package"
        fi
    done

    say info "Installing applications (casks) via Homebrew..."

    installed_casks="$(brew list --cask)"

    for package in "${BREW_CASKS[@]}"; do
        if grep -Eq "\b$package\b" <<< "$installed_casks"; then
            say "Skipping cask ${package} (already installed)"
        else
            "$brew_path" install --cask "$package"
        fi
    done

    if [ "$NPM" = "no" ]; then
        say warning "Skipping npm installation/update"
    else
        say -n info "Installing/updating npm... "
        npm --force --global install npm &>/dev/null
        say success "npm setup complete"
    fi

    fish_path="/usr/local/bin/fish"
    if grep "$fish_path" /etc/shells >/dev/null; then
        say warning "${fish_path} already in /etc/shells"
    else
        say info "Adding fish to /etc/shells..."
        say $fish_path | sudo tee -a /etc/shells
    fi
    say info "To make fish the default shell, run: chsh -s ${fish_path}"

    say info "Running 'brew cleanup'..."
    "$brew_path" cleanup

    say info "Running 'brew autoremove'..."
    "$brew_path" autoremove

    say success "Brew setup complete"
else
    say warning "Skipping Homebrew install since this doesn't appear to be a Mac"
fi

create_dir "${HOME}/.bashrc.d"
create_dir "${HOME}/.config"
create_dir "${HOME}/.config/fish"
create_dir "${HOME}/.config/fish/functions"
create_dir "${HOME}/.doom.d"
create_dir "${HOME}/.local"
create_dir "${HOME}/.local/bin"
create_dir "${HOME}/.ssh"
create_dir "${HOME}/Projects"

link bashrc
link_many bashrc.d/*.rc
link checkoutmanager.cfg
link_many config/fish/*.fish
link_many config/fish/functions/*.fish
link config/fish/functions/additional-blackhole-hosts
link_many doom.d/*.el
link editorconfig
link gitconfig
link gitignore
link hgignore
link hgrc
link ideavimrc
link inputrc
link live-backup.cfg
link_many local/bin/*
link_many local/borg/exclude.*
link_many_with_target local/borg/backup.* "${HOME}/.local/bin"
link npmrc
link profile
link pythonrc
link vimrc
link ssh/config
link "Library/Application Support/pypoetry/config.toml"

if [ "$PYTHON" = "no" ]; then
    say warning "Skipping Python installation"
else
    main_python_version="python${PYTHON_VERSIONS[0]:0:3}"

    if [ "${INSTALL_PYTHON_VERSIONS}" = "yes" ]; then
        python_versions_string=$(printf "%s\n" "${PYTHON_VERSIONS[@]}")
        pyenv_versions=$(pyenv versions --bare)

        if test -f "${PYTHON_VERSIONS_FILE}"; then
            rm "${PYTHON_VERSIONS_FILE}"
            touch "${PYTHON_VERSIONS_FILE}"
            say error "Recreated ${PYTHON_VERSIONS_FILE} (currently empty)"
        fi

        # For each installed pyenv version:
        #
        #   - If the version is in the current install list, do nothing
        #   - If the version isn't in the current install list, uninstall it
        for pyenv_version in $pyenv_versions; do
            if grep -Eq "^${pyenv_version}$" <<< "$python_versions_string"; then
                say info "Not uninstalling Python ${pyenv_version} (in current install list)"
            else
                say warning "Installed Python ${pyenv_version} not in current install list"
                read -r -p "$(colorize warning "Uninstall Python ${pyenv_version}? [yes/no] ")" answer
                if [ "$answer" = "yes" ]; then
                    say warning "Uninstalling Python ${pyenv_version}... "
                    pyenv uninstall -f "$pyenv_version"
                    say success "Done"
                fi
            fi
        done

        # For each Python version in the current install list:
        #
        #   - If the version is already installed, do nothing
        #   - If the version isn't already installed, install it
        for version in "${PYTHON_VERSIONS[@]}"; do
            if grep -Eq "^${version}$" <<< "$pyenv_versions"; then
                say warning "Python ${version} already installed"
                say "${version}" >>"${PYTHON_VERSIONS_FILE}"
                say info "Added ${version} to ${PYTHON_VERSIONS_FILE}"
            else
                read -r -p "$(colorize warning "Install Python ${version}? [y/N] ")" answer
                case "$answer" in
                    y|Y|yes|YES)
                        say info "Installing Python ${version}... "
                        PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install "$version"
                        say success "Done"
                        say "${version}" >>"${PYTHON_VERSIONS_FILE}"
                        say info "Added ${version} to ${PYTHON_VERSIONS_FILE}"
                        ;;
                    *)
                        say error "Skipping installation of Python ${version}... "
                        ;;
                esac
            fi
        done

        eval "$(pyenv init -)"
    fi

    while read -r version; do
        say -n info "Upgrading pip for Python ${version}... "
        "python${version:0:3}" -m pip install --upgrade --upgrade-strategy eager pip >/dev/null
        say success "Done"
    done <"${PYTHON_VERSIONS_FILE}"

    say -n info "Installing/upgrading pipx... "
    $main_python_version -m pip install --user --upgrade --upgrade-strategy eager pipx >/dev/null
    say success "Done"

    say info "Installing/upgrading Python tools... "
    for package in "${PYTHON_PACKAGES[@]}"; do
        say -n info "Installing/upgrading ${package}... "
        $main_python_version -m pipx install \
            --force "$package" \
            '--pip-args=--upgrade --upgrade-strategy eager' \
            >/dev/null
    done
    say success "Python setup complete"
fi

if [ "$VIM_PLUGINS" = "no" ]; then
    say warning "Skipping Vim plugin installation"
else
    mkdir -p "${HOME}/.vim/"{autoload,bundle}
    say -n info "Checking out Pathogen plugins... "
    checkoutmanager co vim-pathogen >/dev/null
    checkoutmanager up vim-pathogen >/dev/null
    say success "Done"
    pathogen_path="${HOME}/.vim/vim-pathogen/autoload/pathogen.vim"
    pathogen_link="${HOME}/.vim/autoload/pathogen.vim"
    if [ -L "$pathogen_link" ]; then
        say warning "pathogen.vim already linked to $(readlink "$pathogen_link")"
    else
        say -n info "Linking ${pathogen_link} to ${pathogen_path}... "
        ln -s "$pathogen_path" "$pathogen_link"
        say success "Done"
    fi
fi

say success "Setup complete"
