function __init
    fish_vi_key_bindings

    set -g -x PROJECT_DIR ~/Projects

    set -g -x fish_prompt_date_format '+%a %b %d %T'
    set -g -x fish_greeting "Shell started" (date $fish_prompt_date_format)
    set -g -x EDITOR vim

    set script_path (status -f)
    set script_dir (dirname $script_path)
    for f in $script_dir/*.fish
        if [ $f != $script_path ]
            source "$f"
        end
    end

    __prepend_path ~/.local/bin
end

function __prepend_path -a path -d "Add path to front of PATH if it's not already in PATH"
    if test -d $path; and not string match -qr $path $PATH
        set -g -x PATH $path $PATH
    end
end

if test -n "$TERM"
    if test "$TERM" = "screen"
        __init
    else if which -s tmux
        echo "Starting tmux..."
        exec tmux
    else
        __init
    end
end
