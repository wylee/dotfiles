fish_vi_key_bindings

set date_format '+%a %b %d %T'

set -g -x fish_greeting "Shell started" (date $date_format)
set -g -x EDITOR vim

if test -d ~/.local/bin
    set -g -x PATH ~/.local/bin $PATH
end

set -g fish_prompt_pwd_dir_length 0

function fish_prompt
    set_color blue
    echo (date $date_format)

    set_color red
    echo -n $USER
    set_color yellow
    echo -n @
    set_color green
    echo (prompt_hostname)

    set_color cyan
    echo -n (prompt_pwd)
    echo (__fish_vcs_prompt)

    set_color yellow
    echo -n '> '

    set_color normal
end

alias back='cd -'

alias j='jobs'
alias 1='fg %1'
alias 2='fg %2'
alias 3='fg %3'
alias 4='fg %4'
alias 5='fg %5'
alias 6='fg %6'
alias 7='fg %7'
alias 8='fg %8'
alias 9='fg %9'

alias ls='/bin/ls -FG'
alias lsa='/bin/ls -aFG'
alias lsl='/bin/ls -lFG'
alias lsal='/bin/ls -alFG'

alias x='exit'

# Go up one or more directories
# Less tedious than `cd ../../../../...`
function up -a times
    set dir (pwd)
    if set -q $times
        set times 1
    end
    for i in (seq $times)
        set dir (dirname $dir)
        if test $dir = /
            break
        end
    end
    cd $dir
end

function tmux-session -a name
    if set -q $name
        echo 'Session name is required'
        return 1
    end
    set path "~/.tmux/$name-session.conf"
    if test ! -f $path
        echo "Could not find tmux session config: $path"
        return 2
    end
    tmux source-file $path
end
