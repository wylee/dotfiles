if not type --query _original_cd
    functions -c cd _original_cd
end

function cd -d "cd and activate project/env"
    _original_cd $argv
    if [ "$PWD" = "$HOME" ]
        deactivateenv silent
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
        if not string match -q "/*" "$env_dir"
            set env_dir $PROJECT_DIR/$env_dir
        end
    else if set -q _ENV_CURRENT
        set env_dir $_ENV_CURRENT
    end

    if set -q env_dir[1]
        _original_cd "$env_dir"
        if ! activateenv
            # Deactivate current env (if there is one)
            deactivateenv silent
        end
    else
        set_color red
        echo "No env passed and no env is already active" 1>&2
        echo "Changing to $PROJECT_DIR instead, which contains the following projects:" 1>&2
        set_color normal
        _original_cd $PROJECT_DIR
        for f in $PROJECT_DIR/*
            echo (basename "$f")
        end
        deactivateenv silent
    end
end

function activateenv
    # Do nothing if this env is already active
    if test "$PWD" = "$_ENV_CURRENT"
        return
    end

    set virtualenv_candidates .venv .virtualenv .env
    set virtualenv_dir
    set virtualenv_bin

    set rails_script bin/rails

    set node_candidates . frontend */{frontend,static} src/{frontend,static} src/*/{frontend,static}
    set node_bin

    set rust_candidates Cargo.toml

    set is_virtualenv
    set is_rails_env
    set is_node_env
    set is_rust_env

    for dir in $virtualenv_candidates
        if test -f "$dir/bin/python"
            set is_virtualenv true
            set virtualenv_dir $dir
            set virtualenv_bin $dir/bin
            break
        end
    end

    if test -f "$rails_script"
        set is_rails_env true
        set rails_bin (dirname $rails_script)
    end

    for dir in $node_candidates
        if test -d "$dir/node_modules"
            set is_node_env true
            set node_bin $dir/node_modules/.bin
            break
        end
    end

    for file in $rust_candidates
        if test -f "$file"
            set is_rust_env true
            break
        end
    end

    if test -z "$is_virtualenv" -a -z "$is_rails_env" -a -z "$is_node_env" -a -z "$is_rust_env"
        if [ "$argv[1]" != "silent" ]
            set_color red
            echo "This is not an env directory" 1>&2
            set_color normal
        end
        return 1
    end

    deactivateenv silent

    set -gx PROJECT_NAME (basename $PWD)
    set -gx _ENV_CURRENT $PWD
    set -gx _ENV_ORIGINAL_PATH $PATH

    if test -n "$is_node_env"
        set -gx PATH $PWD/$node_bin $PATH
        set -gx _ENV_TYPE $_ENV_TYPE node
        test -f $PWD/.nvmrc; and nvm use
    end

    if test -n "$is_rust_env"
        set -gx _ENV_TYPE $_ENV_TYPE rust
    end

    if test -n "$is_rails_env"
        set -gx PATH $PWD/$rails_bin $PATH
        set -gx _ENV_TYPE $_ENV_TYPE rails
    end

    if test -n "$is_virtualenv"
        set -gx PATH $PWD/$virtualenv_bin $PATH
        set -gx VIRTUAL_ENV $_ENV_CURRENT/$virtualenv_dir
        set -gx _ENV_TYPE $_ENV_TYPE virtualenv
    end

    hash -r 2>/dev/null

    if [ "$argv[1]" != "silent" ]
        set_color green
        set -l type (string join ', ' $_ENV_TYPE)
        echo "Activated env $_ENV_CURRENT ($type)"
        set_color normal
    end
end

function deactivateenv
    if set -q _ENV_CURRENT
        set -l env_current $_ENV_CURRENT
        set -l env_type $_ENV_TYPE
        set -gx PATH $_ENV_ORIGINAL_PATH
        set -e PROJECT_NAME
        set -e VIRTUAL_ENV
        set -e _ENV_CURRENT
        set -e _ENV_ORIGINAL_PATH
        set -e _ENV_TYPE
        if contains node $env_type
            nvm use node
        end
        hash -r 2>/dev/null
        if [ "$argv[1]" != "silent" ]
            set_color red
            echo "Deactivated env $env_current"
            set_color normal
        end
    else
        if [ "$argv[1]" != "silent" ]
            set_color red
            echo "No env is active" 1>&2
            set_color normal
        end
        return 1
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
