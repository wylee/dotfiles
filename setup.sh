#!/bin/bash
#
# First run on new machine:
#
#     ssh-keygen -t rsa -f ~/.ssh/id_rsa-github
#     curl -o ~/.ssh/config https://raw.githubusercontent.com/wylee/dotfiles/main/ssh/config
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
    bash-completion@2
    bitwarden-cli
    direnv
    editorconfig
    exiftool
    fish
    git
    neovim
    node
    pass
    pwgen
    python@3.12
    ripgrep
    shellcheck
    starship
    uv
    vim
)

BREW_CASKS=(
    dropbox
    firefox
    font-fira-mono-nerd-font
    iterm2
    jetbrains-toolbox
    sourcetree
    visual-studio-code
)

PYTHON_PACKAGES=(
    bpython
    checkoutmanager
    com.wyattbaldwin.make-release
    poetry
    ruff
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
    if [ "$type" = "warning" ] ||  [ "$type" = "error" ]; then
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
    #     $1: Source path relative to root of dot files repo or an
    #         absolute path. If the path is relative, the dotfiles
    #         repo directory will be prepended.
    #
    #         Example: bashrc.d/alias.rc -> $REPO_DIR/bashrc.d/alias.rc
    #         Example: /some/absolute/path -> /some/absolute/path
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

    if [ "${1:0:1}" = "/" ]; then
        source="${1}"
        if [ ! -f "$source" ] && [ ! -d "$source" ]; then
            say error "Source does not exist: ${source}"
            return 1
        fi
    else
        source="${REPO_DIR}/${1}"
        if [ ! -f "$source" ] && [ ! -d "$source" ]; then
            say error "Source does not exist in .files repo: ${source}"
            return 1
        fi
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
        "$BREW_PATH" tap homebrew/cask-fonts
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

function main () {
    local with_brew="yes"
    local with_python="yes"
    local with_vim_plugins="yes"

    local bash_path="${BREW_BIN}/bash"
    local fish_path="${BREW_BIN}/fish"

    # vim
    local vim_config_dir="${HOME}/.vim"
    local pathogen_path="${vim_config_dir}/vim-pathogen/autoload/pathogen.vim"
    local pathogen_link="${vim_config_dir}/autoload/pathogen.vim"

    # neovim
    local nvim_config_dir="${HOME}/.config/nvim"
    local nvim_pathogen_path="${nvim_config_dir}/vim-pathogen/autoload/pathogen.vim"
    local nvim_pathogen_link="${nvim_config_dir}/autoload/pathogen.vim"

    while [[ $# -gt 0 ]]; do
        option="$1"
        case $option in
            --no-brew)
                with_brew="no"
                ;;
            --no-python)
                with_python="no"
                ;;
            --no-vim-plugins)
                with_vim_plugins="no"
                ;;
            -h|--help)
                say "Install local config (AKA dot files)"
                say ""
                say "Usage: ./setup.sh"
                say "    --no-brew => Skip installation of Homebrew and packages"
                say "    --no-python => Skip all Python-related setup"
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

        # Install Python tools
        if [ "$with_python" = "no" ]; then
            say warning "Skipping all Python setup"
        else
            say info "Installing Python tools... "
            for package in "${PYTHON_PACKAGES[@]}"; do
                say -n info "Installing/upgrading ${package}... "
                uv tool install "$package" >/dev/null
                say success "Done"
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
    create_dir "${nvim_config_dir}"
    create_dir "${nvim_config_dir}/ftdetect"
    create_dir "${nvim_config_dir}/syntax"
    create_dir "${HOME}/.doom.d"
    create_dir "${HOME}/.local"
    create_dir "${HOME}/.local/bin"
    create_dir "${HOME}/.ssh"
    create_dir "${HOME}/Library/Application Support/pypoetry"
    create_dir "${HOME}/Projects"

    link bashrc
    link_many bashrc.d/*.rc
    link checkoutmanager.cfg
    link_many config/fish/*.fish
    link_many config/fish/functions/*.fish
    link config/fish/functions/additional-blackhole-hosts
    link config/fish/functions/allowed-blackhole-hosts
    link_many config/live-backup/*
    link_many config/nvim/*.lua
    link_many config/nvim/*.vim
    link_many config/nvim/ftdetect/*.vim
    link_many config/nvim/syntax/*.vim
    link config/starship.toml
    link_many doom.d/*.el
    link gitconfig
    link gitignore
    link hgignore
    link hgrc
    link ideavimrc
    link inputrc
    link_many local/bin/*
    link npmrc
    link profile
    link pythonrc
    link vimrc
    link ssh/config
    link "Library/Application Support/pypoetry/config.toml"

    if [ "$with_vim_plugins" = "no" ]; then
        say warning "Skipping Vim plugin installation"
    else
        mkdir -p "${vim_config_dir}/"{autoload,bundle}
        say -n info "Checking out Pathogen plugins for vim... "
        checkoutmanager co vim-pathogen >/dev/null
        checkoutmanager up vim-pathogen >/dev/null
        say success "Done"

        # NOTE: $pathogen_path is created by checkoutmanager
        link "$pathogen_path" "$pathogen_link"

        mkdir -p "${nvim_config_dir}/"{autoload,bundle}
        say -n info "Checking out Pathogen plugins for nvim... "
        checkoutmanager co nvim-pathogen >/dev/null
        checkoutmanager up nvim-pathogen >/dev/null
        say success "Done"

        # NOTE: $nvim_pathogen_path is created by checkoutmanager
        link "$nvim_pathogen_path" "$nvim_pathogen_link"
    fi

    say success "Setup complete"
}

main "$@"
