set PYENV_ROOT (brew --prefix)/var/pyenv
set -g -x PATH $PYENV_ROOT/shims $PATH
pyenv rehash
