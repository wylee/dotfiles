alias back 'cd -'

alias j 'jobs'
alias 1 'fg %1'
alias 2 'fg %2'
alias 3 'fg %3'
alias 4 'fg %4'
alias 5 'fg %5'
alias 6 'fg %6'
alias 7 'fg %7'
alias 8 'fg %8'
alias 9 'fg %9'

alias ls '/bin/ls -FG'
alias lsa '/bin/ls -aFG'
alias lsl '/bin/ls -lFG'
alias lsal '/bin/ls -alFG'

alias x 'exit'

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
