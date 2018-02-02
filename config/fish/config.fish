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
