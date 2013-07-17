if [ -n "${BASH_VERSION}" ]; then
    BASHRC="${HOME}/.bashrc"
    if [ -f "${BASHRC}" ]; then
        . "${BASHRC}"
    fi
fi

# Local scripts (they take priority over anything else)
LOCAL_BIN="${HOME}/.local/bin"
if [ -d "$LOCAL_BIN" ]; then
    PATH="${LOCAL_BIN}:${PATH}"
fi

export PATH
