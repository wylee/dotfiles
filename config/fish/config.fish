function __init
    if status --is-login
        fish_vi_key_bindings

        set -gx EDITOR vim
        set -gx PROJECT_DIR ~/Projects

        set -gx fish_prompt_date_format '+%a %b %d %T'
        set -gx fish_greeting "Shell started" (date $fish_prompt_date_format)
    end

    set script_path (status -f)
    set script_dir (dirname $script_path)
    for f in $script_dir/*.fish
        if test "$f" != "$script_path"
            source "$f"
        end
    end

    __prepend_path /usr/local/opt/postgresql@9.4/bin
    __prepend_path ~/.local/bin
end

function __prepend_path -a path -d "Add path to front of PATH if it's not already in PATH"
    if test -d $path; and not string match -qr $path $PATH
        set -gx PATH $path $PATH
    end
end

__init
