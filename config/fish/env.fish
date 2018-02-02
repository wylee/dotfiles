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

function activateenv -a option
    set python_bin .env/bin
    set python_exe $python_bin/python
    set node_modules_bin node_modules/.bin

    if test -f $python_exe
        set type virtualenv
    else if test -d node_modules
        set type node
    else
        if [ "$option" != "silent" ]
            set_color red
            echo "This is not an env directory" 1>&2
            set_color normal
        end
        return
    end

    # Do nothing if this virtualenv is already active
    if [ "$PWD" = "$_ENV_CURRENT" ]
        return
    end

    deactivateenv

    set -g -x PROJECT_NAME (basename $PWD)
    set -g -x _ENV_CURRENT $PWD
    set -g -x _ENV_ORIGINAL_PATH $PATH

    if [ "$type" = "virtualenv" ]
        if [ -d node_modules/.bin ]
            set -g -x PATH $PWD/$node_modules_bin $PATH
        else if [ -d "$PROJECT_NAME/static/$node_modules_bin" ]
            set -g -x PATH $PWD/$PROJECT_NAME/static/$node_modules_bin $PATH
        end
        set -g -x PATH $PWD/$python_bin $PATH
    else if [ "$type" = "node" ]
        set -g -x PATH $PWD/$node_modules_bin $PATH
    end

    hash -r 2>/dev/null
    set_color green
    echo -e "Activated $_ENV_CURRENT ($type)"
    set_color normal
end

function deactivateenv
    if set -q _ENV_CURRENT
        set env_current $_ENV_CURRENT
        set -e PROJECT_NAME
        set -e _ENV_CURRENT
        set -g -x PATH $_ENV_ORIGINAL_PATH
        set -e _ENV_ORIGINAL_PATH
        hash -r 2>/dev/null
        set_color red
        echo "Deactivated $env_current"
        set_color normal
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
