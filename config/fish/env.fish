if not type --quiet _original_cd
    functions -c cd _original_cd
end

function cd -d "cd and activate project/env"
    _original_cd $argv
    if [ "$PWD" = "$HOME" ]
        deactivateenv
    else
        activateenv silent
    end
end

function cdenv -a env_dir
    # Args:
    #     env_dir: A subdirectory of $PROJECT_DIR [optional]
    #
    # If env_dir is passed (as $1), cd into $PROJECT_DIR/$env_dir and
    # then activate the virtualenv in that directory.
    #
    # If env_dir isn't passed, cd into the current env directory.
    if set -q env_dir[1]
        if not string match -q "/*" $env_dir
            set env_dir $PROJECT_DIR/$env_dir
        end
    else if set -q _ENV_CURRENT
        set env_dir $_ENV_CURRENT
    end

    if set -q env_dir[1]
        _original_cd $env_dir
        activateenv
    else
        set_color red
        echo "No env passed and no env is already active" 1>&2
        echo "Changing to $PROJECT_DIR instead, which contains the following projects:" 1>&2
        echo
        set_color normal
        _original_cd $PROJECT_DIR
        for f in $PROJECT_DIR/*
            echo "   " (basename $f)
        end
        echo
        deactivateenv
    end
end

function activateenv
    set virtualenv_dir .env
    set virtualenv_bin $virtualenv_dir/bin
    set python_exe $virtualenv_bin/python

    set alt_virtualenv_dir .venv
    set alt_virtualenv_bin $alt_virtualenv_dir/bin
    set alt_python_exe $alt_virtualenv_bin/python

    set node_modules_bin node_modules/.bin
    set alt_node_modules_bin */static/node_modules/.bin
    set alt_node_modules_bin $alt_node_modules_bin[1]

    set is_virtualenv
    set is_node_env

    if test -f "$python_exe"
        set is_virtualenv true
    else if test -f "$alt_python_exe"
        set is_virtualenv true
        set virtualenv_dir $alt_virtualenv_dir
        set virtualenv_bin $alt_virtualenv_bin
        set python_exe $alt_python_exe
    end

    if test -d "$node_modules_bin"
        set is_node_env "true"
    else if test -d "$alt_node_modules_bin"
        set is_node_env true
        set node_modules_bin $alt_node_modules_bin
    end

    if test -z "$is_virtualenv" -a -z "$is_node_env"
        if [ "$argv[1]" != "silent" ]
            set_color red
            echo "This is not an env directory" 1>&2
            set_color normal
        end
        return
    end

    # Do nothing if this virtualenv is already active
    if test "$PWD" = "$_ENV_CURRENT"
        return
    end

    deactivateenv

    set -gx PROJECT_NAME (basename $PWD)
    set -gx _ENV_CURRENT $PWD
    set -gx _ENV_ORIGINAL_PATH $PATH

    if test -n "$is_virtualenv"
        set env_type virtualenv
        set -gx PATH $PWD/$virtualenv_bin $PATH
        set -gx VIRTUAL_ENV $_ENV_CURRENT/$virtualenv_dir
    end

    if test -n "$is_node_env"
        set -gx PATH $PWD/$node_modules_bin $PATH
        if test -n "$env_type"
            set env_type "$env_type, node"
        else
            set env_type "node"
        end
    end

    hash -r 2>/dev/null

    if [ "$argv[1]" != "silent" ]
        set_color green
        echo -e "Activated $_ENV_CURRENT ($env_type)"
        set_color normal
    end
end

function deactivateenv
    if set -q _ENV_CURRENT
        set env_current $_ENV_CURRENT
        set -e PROJECT_NAME
        set -e _ENV_CURRENT
        set -e VIRTUAL_ENV
        set -gx PATH $_ENV_ORIGINAL_PATH
        set -e _ENV_ORIGINAL_PATH
        hash -r 2>/dev/null
        if [ "$argv[1]" != "silent" ]
            set_color red
            echo "Deactivated $env_current"
            set_color normal
        end
    end
end

function _cdenv_completions
    for dir in $PROJECT_DIR/*/
        printf (basename $dir)" "
        for subdir in $dir/*/
            printf (basename $dir)/(basename $subdir)" "
        end
    end
end

complete -c cdenv -f -a (_cdenv_completions)
