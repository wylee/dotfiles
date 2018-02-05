# PYENV_ROOT is where Python versions will be installed
set -gx PYENV_ROOT (brew --prefix)/var/pyenv

# This sets up pyenv shims and bash completion; run `pyenv init -` to
# see everything it does.
status --is-interactive; and source (pyenv init -|psub)
