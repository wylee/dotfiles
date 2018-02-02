set -g fish_prompt_pwd_dir_length 0

function fish_prompt
    set_color blue
    echo (date $fish_prompt_date_format)

    set_color red
    echo -n $USER
    set_color yellow
    echo -n @
    set_color green
    echo (prompt_hostname)

    set_color cyan
    echo -n (prompt_pwd)
    echo -n (__fish_vcs_prompt)
    if set -q _ENV_CURRENT
        echo -n " (env:"(basename $_ENV_CURRENT)")"
    end
    echo

    set_color yellow
    echo -n "> "

    set_color normal
end
