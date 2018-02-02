function tmux-session -a name
    if not set -q name[1]
        echo 'Session name is required'
        return 1
    end

    set path ~/.tmux/$name-session.conf

    if test -f $path
        tmux source-file $path
    else
        echo "Could not find tmux session config: $path"
        return 2
    end
end
