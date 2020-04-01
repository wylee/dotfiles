function __init
    # XXX: Needs to be set for both login and non-login shells
    set -gx PROJECT_DIR ~/Projects

    if status --is-login
        fish_vi_key_bindings
        set -gx fish_prompt_date_format '+%a %b %d %T'
        set -gx fish_greeting "Shell started" (date $fish_prompt_date_format)
        set -gx EDITOR vim
    end

    __prepend_path /usr/local/bin
    __prepend_path /usr/local/opt/postgresql@9.4/bin

    set script_path (status -f)
    set script_dir (dirname $script_path)
    for f in $script_dir/*.fish
        if test "$f" != "$script_path"
            source "$f"
        end
    end

    __prepend_path ~/.local/bin
end

function __prepend_path -a path -d "Add path to front of PATH if it's not already in PATH"
    if test -d $path; and not string match -qr $path $PATH
        set --prepend PATH $path
    end
end

__init
