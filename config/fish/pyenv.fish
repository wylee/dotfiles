# PYENV_ROOT is where Python versions will be installed
set -gx PYENV_ROOT (brew --prefix)/var/pyenv

# This sets up pyenv shims and bash completion; run `pyenv init -` to
# see everything it does.
status --is-interactive; and source (pyenv init -|psub)

function pyenv-install
    set cppflags
    set ldflags
    set configure_opts "--enable-shared"

    for lib in openssl readline zlib
        set cppflags $cppflags "-I"(brew --prefix $lib)/include
        set ldflags $ldflags "-L"(brew --prefix $lib)/lib
    end

    begin
        set -lx CPPFLAGS "$cppflags"
        set -lx LDFLAGS "$ldflags"
        set -lx PYTHON_CONFIGURE_OPTS "$configure_opts"
        echo "Running `pyenv install $argv` with:"
        echo "CPPFLAGS=$CPPFLAGS"
        echo "LDFLAGS=$LDFLAGS"
        echo "PYTHON_CONFIGURE_OPTS=$PYTHON_CONFIGURE_OPTS"
        pyenv install $argv
    end
end
