set -l BREW_PREFIX (brew --prefix)

# PYENV_ROOT is where Python versions will be installed
set -gx PYENV_ROOT "$BREW_PREFIX/var/pyenv"

# This sets up pyenv shims and bash completion; run `pyenv init -` to
# see everything it does.
status is-login; and pyenv init --path | source
pyenv init - | source

function pyenv-install
    begin
        set -lx CPPFLAGS "-I$BREW_PREFIX/opt/zlib/include"
        set -lx LDFLAGS "-L$BREW_PREFIX/opt/zlib/lib"
        set -lx PYTHON_CONFIGURE_OPTS "--enable-shared"
        echo "Running `pyenv install $argv` with:"
        echo "CPPFLAGS=$CPPFLAGS"
        echo "LDFLAGS=$LDFLAGS"
        echo "PYTHON_CONFIGURE_OPTS=$PYTHON_CONFIGURE_OPTS"
        pyenv install $argv
    end
end
