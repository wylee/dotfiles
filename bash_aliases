alias back='cd -'

alias j='jobs'
alias 1='%1'
alias 2='%2'
alias 3='%3'
alias 4='%4'
alias 5='%5'
alias 6='%6'
alias 7='%7'
alias 8='%8'
alias 9='%9'

function x {
    local j="$(jobs)"
    if [ "$j" ]; then
        echo "There are jobs running (kill them or use exit directly):"
        echo "${j}"
        return 1
    fi
    exit
}

case $OSTYPE in
    linux-gnu*)
        alias ls='/bin/ls -F --color'
        alias lsa='/bin/ls -aF --color'
        alias lsl='/bin/ls -lF --color'
        alias lsal='/bin/ls -alF --color'
        ;;
    darwin*)
        alias ls='/bin/ls -FG'
        alias lsa='/bin/ls -aFG'
        alias lsl='/bin/ls -lFG'
        alias lsal='/bin/ls -alFG'
        ;;
    *)
        echo 'No ls aliases set (could not determine OS type).' 1>&2
        ;;
esac

# Go up one or directories
# Less tedious than `cd ../../../../...`
function up {
    times=${1:-1}
    start_pwd=$PWD
    for (( i=0; i<times; ++i )); do
        cd ..
    done
    end_pwd=$PWD
    cd $start_pwd
    cd $end_pwd
}

apt=$(which aptitude apt-get 2>/dev/null | head -1)
if [ "$apt" ]; then
    alias update="sudo $apt update"
    alias upgrade="sudo $apt upgrade"
    alias upgrade-d="sudo $apt dist-upgrade"
fi
