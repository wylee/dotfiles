# PYENV_ROOT is where Python versions will be installed
set -gx PYENV_ROOT (brew --prefix)/var/pyenv

# This sets up pyenv shims and bash completion; run `pyenv init -` to
# see everything it does.
status --is-interactive; and source (pyenv init -|psub)

function pyenv-install
    begin
        set -lx CPPFLAGS "-I/usr/local/opt/zlib/include"
        set -lx LDFLAGS "-L/usr/local/opt/zlib/lib"
        set -lx PYTHON_CONFIGURE_OPTS "--enable-shared"
        echo "Running `pyenv install $argv` with:"
        echo "CPPFLAGS=$CPPFLAGS"
        echo "LDFLAGS=$LDFLAGS"
        echo "PYTHON_CONFIGURE_OPTS=$PYTHON_CONFIGURE_OPTS"
        pyenv install $argv
    end
end
