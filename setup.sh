#!/bin/bash
#
# First run on new machine:
#
#     ssh-keygen -t rsa -f ~/.ssh/id_rsa-github
#     git clone git@github.com:wylee/dotfiles ~/.files

set -eu -o pipefail
shopt -s failglob

OS_NAME="$(uname -s)"
ARCH_NAME="$(uname -m)"
REPO_DIR="${HOME}/.files"

case $OS_NAME in
    Darwin)
        ;;
    *)
        say error "Unsupported OS: ${OS_NAME}"
        exit 1
esac

case $ARCH_NAME in
    arm64)
        BREW_PREFIX="/opt/homebrew"
        ;;
    x86_64)
        BREW_PREFIX="/usr/local"
        ;;
    *)
        say error "Unsupported archictecture: ${ARCH_NAME}"
        exit 1
esac

BREW_BIN="${BREW_PREFIX}/bin"
BREW_PATH="${BREW_BIN}/brew"

BREW_PACKAGES=(
    bash
    bash-completion
    bitwarden-cli
    borgbackup
    editorconfig
    exiftool
    fish
    git
    hugo
    node
    neovim
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
    iterm2
    jetbrains-toolbox
    signal
    sourcetree
    visual-studio-code
)

PYTHON_VERSIONS=(
    3.10.0
    3.9.7
    3.8.12
    3.7.12
    3.6.15
)

PYTHON_VERSIONS_FILE="${HOME}/.python-version"

PYTHON_PACKAGES=(
    bpython
    checkoutmanager
    com.wyattbaldwin.make-release
    poetry
    totp
    twine
)

function create_color () {
    tput "$@" 2>/dev/null || echo ""
}

RED="$(create_color setaf 1)"
GREEN="$(create_color setaf 2)"
BLUE="$(create_color setaf 4)"
YELLOW="$(create_color setaf 3)"
RESET="$(create_color sgr0)"

function colorize () {
    # Colorize string by type (or color)
    #
    # Args:
    #     $1 type: type | color
    #     $2 string
    #
    # Type:
    #     | default (none)
    #     | info (blue)
    #     | success (green)
    #     | warning (yellow)
    #     | error (red)
    #
    # Alternatively, a color string, like "RED", can be passed instead
    # of a type name.
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
        message="${type}$2${RESET}"
    fi
    echo -n "$message"
}

function say () {
    # Echo with color
    #
    # Args:
    #     $1 message type | message
    #     $2 message?
    #
    # Message type: default | info | success | warning | error
    #
    # If one arg is passed, it's considered the message and will be
    # printed with the default style (i.e., no style). If two args are
    # passed, the first is the type and the second is the message.
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

function install_brew () {
    # Install Homebrew & packages
    if [ -f "$BREW_PATH" ]; then
        say warning "Homebrew already installed at prefix $($BREW_PATH --prefix)"
        say info "Updating Homebrew..."
        "$BREW_PATH" update
        say info "Upgrading Homebrew packages..."
        "$BREW_PATH" upgrade --formula
        say info "Upgrading Homebrew apps (AKA casks)..."
        "$BREW_PATH" upgrade --cask
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    say info "Installing Homebrew packages..."

    installed_formulas="$("$BREW_PATH" list --formula)"

    for package in "${BREW_PACKAGES[@]}"; do
        if grep -Eq "\b$package\b" <<< "$installed_formulas"; then
            say "Skipping package ${package} (already installed)"
        else
            "$BREW_PATH" install "$package"
        fi
    done

    say info "Installing applications (casks) via Homebrew..."

    installed_casks="$("$BREW_PATH" list --cask)"

    if [ "$ARCH_NAME" = "x86_64" ]; then
        BREW_CASKS+=("firefox-developer-edition")
    else
        say warning "Cask firefox-developer-edition not available on this platform"
    fi

    for package in "${BREW_CASKS[@]}"; do
        if grep -Eq "\b$package\b" <<< "$installed_casks"; then
            say "Skipping cask ${package} (already installed)"
        else
            "$BREW_PATH" install --cask "$package"
        fi
    done
}

function install_python_versions () {
    local pyenv_path="${BREW_BIN}/pyenv"

    python_versions_string=$(printf "%s\n" "${PYTHON_VERSIONS[@]}")
    pyenv_versions=$("$pyenv_path" versions --bare)

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
                "$pyenv_path" uninstall -f "$pyenv_version"
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
                    PYTHON_CONFIGURE_OPTS="--enable-shared" "$pyenv_path" install "$version"
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

    eval "$("$pyenv_path" init -)"
}

function main () {
    local with_brew="yes"
    local with_npm="yes"
    local with_python="yes"
    local with_python_versions="no"
    local with_vim_plugins="yes"

    local npm_path="${BREW_BIN}/npm"
    local bash_path="${BREW_BIN}/bash"
    local fish_path="${BREW_BIN}/fish"

    local main_python_version="python${PYTHON_VERSIONS[0]:0:3}"

    # Vim plugins
    local pathogen_path="${HOME}/.vim/vim-pathogen/autoload/pathogen.vim"
    local pathogen_link="${HOME}/.vim/autoload/pathogen.vim"

    while [[ $# -gt 0 ]]; do
        option="$1"
        case $option in
            --no-brew)
                with_brew="no"
                ;;
            --no-npm)
                with_npm="no"
                ;;
            --no-python)
                with_python="no"
                ;;
            --with-python-versions)
                with_python_versions="yes"
                ;;
            --no-vim-plugins)
                with_vim_plugins="no"
                ;;
            -h|--help)
                say "Install local config (AKA dot files)"
                say ""
                say "Usage: ./setup.sh"
                say "    --no-brew => Skip installation of Homebrew and packages"
                say "    --no-npm => Skip npm update"
                say "    --no-python => Skip all Python-related setup"
                say "    --with-python-versions => Skip installation of Python versions"
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

    if [ "$with_brew" = "no" ]; then
        say warning "Skipping Homebrew installation and setup"
    else
        install_brew

        # Update npm
        if [ "$with_npm" = "no" ]; then
            say warning "Skipping npm installation/update"
        else
            say -n info "Updating npm... "
            PATH="${BREW_BIN}:${PATH}" \
                "$npm_path" --force --global install npm &>/dev/null
            say success "npm setup complete"
        fi

        # Configure shells
        if grep "$bash_path" /etc/shells >/dev/null; then
            say warning "${bash_path} already in /etc/shells"
        else
            say info "Adding bash to /etc/shells..."
            say "$bash_path" | sudo tee -a /etc/shells
        fi

        if grep "$fish_path" /etc/shells >/dev/null; then
            say warning "${fish_path} already in /etc/shells"
        else
            say info "Adding fish to /etc/shells..."
            say "$fish_path" | sudo tee -a /etc/shells
        fi
        say info "To make fish the default shell, run: chsh -s ${fish_path}"

        # Install Python versions & packages
        if [ "$with_python" = "no" ]; then
            say warning "Skipping all Python setup"
        else
            if [ "${with_python_versions}" = "no" ]; then
                say warning "Skipping installation of Python versions (use --with-python-versions to install them)"
            else
                install_python_versions
            fi

            while read -r version; do
                say -n info "Upgrading pip for Python ${version}... "
                "python${version:0:3}" -m pip install --upgrade --upgrade-strategy eager pip >/dev/null
                say success "Done"
            done <"${PYTHON_VERSIONS_FILE}"

            say -n info "Installing/upgrading pipx... "
            "$main_python_version" -m pip install --user --upgrade --upgrade-strategy eager pipx >/dev/null
            say success "Done"

            say info "Installing/upgrading Python tools... "
            for package in "${PYTHON_PACKAGES[@]}"; do
                say -n info "Installing/upgrading ${package}... "
                "$main_python_version" -m pipx install \
                    --force "$package" \
                    '--pip-args=--upgrade --upgrade-strategy eager' \
                    >/dev/null
            done
            say success "Python setup complete"
        fi

        say info "Running 'brew cleanup'..."
        "$BREW_PATH" cleanup

        say info "Running 'brew autoremove'..."
        "$BREW_PATH" autoremove

        say success "Brew setup complete"
    fi

    create_dir "${HOME}/.bashrc.d"
    create_dir "${HOME}/.config"
    create_dir "${HOME}/.config/fish"
    create_dir "${HOME}/.config/fish/functions"
    create_dir "${HOME}/.config/live-backup"
    create_dir "${HOME}/.config/nvim"
    create_dir "${HOME}/.config/nvim/ftdetect"
    create_dir "${HOME}/.config/nvim/syntax"
    create_dir "${HOME}/.doom.d"
    create_dir "${HOME}/.local"
    create_dir "${HOME}/.local/bin"
    create_dir "${HOME}/.local/borg"
    create_dir "${HOME}/.ssh"
    create_dir "${HOME}/Library/Application Support/pypoetry"
    create_dir "${HOME}/Projects"

    link bashrc
    link_many bashrc.d/*.rc
    link checkoutmanager.cfg
    link_many config/fish/*.fish
    link_many config/fish/functions/*.fish
    link config/fish/functions/additional-blackhole-hosts
    link_many config/nvim/*.vim
    link_many config/nvim/ftdetect/*.vim
    link_many config/nvim/syntax/*.vim
    link_many doom.d/*.el
    link gitconfig
    link gitignore
    link hgignore
    link hgrc
    link ideavimrc
    link inputrc
    link_many config/live-backup/*
    link_many local/bin/*
    link_many local/borg/exclude.*
    link_many_with_target local/borg/backup.* "${HOME}/.local/bin"
    link npmrc
    link profile
    link pythonrc
    link vimrc
    link ssh/config
    link "Library/Application Support/pypoetry/config.toml"

    if [ "$with_vim_plugins" = "no" ]; then
        say warning "Skipping Vim plugin installation"
    else
        mkdir -p "${HOME}/.vim/"{autoload,bundle}
        say -n info "Checking out Pathogen plugins... "
        checkoutmanager co vim-pathogen >/dev/null
        checkoutmanager up vim-pathogen >/dev/null
        say success "Done"
        if [ -L "$pathogen_link" ]; then
            say warning "pathogen.vim already linked to $(readlink "$pathogen_link")"
        else
            say -n info "Linking ${pathogen_link} to ${pathogen_path}... "
            ln -s "$pathogen_path" "$pathogen_link"
            say success "Done"
        fi
    fi

    say success "Setup complete"
}

main "$@"
