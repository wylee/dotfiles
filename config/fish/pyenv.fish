set PYENV_ROOT (brew --prefix)/var/pyenv
__prepend_path $PYENV_ROOT/shims
pyenv rehash
