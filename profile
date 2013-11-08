if [ -n "${BASH_VERSION}" ]; then
    BASHRC="${HOME}/.bashrc"
    if [ -f "${BASHRC}" ]; then
        . "${BASHRC}"
    fi
fi
