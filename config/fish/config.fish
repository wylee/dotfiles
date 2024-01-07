function __init
    if test -d /opt/homebrew/lib
        set -gx DYLD_LIBRARY_PATH /opt/homebrew/lib
    end

    set -gx PROJECT_DIR ~/Projects

    status --is-interactive; or exit

    # Interactive ------------------------------------------------------

    if status --is-login
        fish_vi_key_bindings
        set -gx fish_prompt_date_format '+%a %b %d %T'
        set -gx fish_greeting "Shell started" (date $fish_prompt_date_format)
        set -gx EDITOR vim
    end

    __prepend_path /opt/homebrew/bin
    __prepend_path /opt/homebrew/sbin
    __prepend_path /usr/local/bin
    __prepend_path /usr/local/sbin

    set script_path (status -f)
    set script_dir (dirname $script_path)
    for f in $script_dir/*.fish
        if test "$f" != "$script_path"
            source "$f"
        end
    end

    __prepend_path ~/go/bin
    __prepend_path ~/.cargo/bin
    __prepend_path ~/.local/bin

    starship init fish | source
end

function __prepend_path -a path -d "Add path to front of PATH if it's not already in PATH"
    if test -d $path; and not string match -qr $path $PATH
        set --prepend PATH $path
    end
end

# Fixes slow command completion, which appears to be an Mac-specific
# issue due to the way `apropos` and `whatis` are implemented. The
# __fish_describe_command function is called when tab-completing
# a command name and shows a list of commands of with descriptions in
# parentheses. Since I never look at those descriptions, disabling them
# is no big deal.
function __fish_describe_command; end

__init
