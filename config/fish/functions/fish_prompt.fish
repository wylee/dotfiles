set -g fish_prompt_pwd_dir_length 0

function fish_prompt
    # First line: date and time
    set_color blue
    echo (date $fish_prompt_date_format)

    # Second line: user and host
    set_color red
    echo -n "$USER"
    set_color yellow
    echo -n "@"
    set_color green
    echo (prompt_hostname)

    # Third line: PWD
    set_color cyan
    echo (prompt_pwd)

    # Fourth line: env and VCS info
    set vcs_prompt (__fish_vcs_prompt)
    set vcs_prompt (string trim -l -c ' (' "$vcs_prompt")
    set vcs_prompt (string trim -r -c ' )' "$vcs_prompt")

    if test -n "$vcs_prompt"
        if git rev-parse --show-toplevel 1>/dev/null 2>/dev/null
            set vcs_prompt "git:$vcs_prompt"
        else if hg root 1>/dev/null 2>/dev/null
            set vcs_prompt "hg:$vcs_prompt"
        else
            set vcs_prompt "vcs:$vcs_prompt"
        end
    end

    if set -q _ENV_CURRENT
        echo -n "env:"(basename $_ENV_CURRENT)
        test -n "$vcs_prompt"; and echo " - $vcs_prompt"; or echo
    else if test -n "$vcs_prompt"
        echo "$vcs_prompt"
    end

    # Fifth line: prompt
    set_color yellow
    echo -n "> "

    set_color normal
end
