function up -a N -d "Go up N directories; less tedious than `cd ../../../../...`"
    set dir (pwd)
    if not set -q N[1]
        set N 1
    end
    for i in (seq $N)
        set dir (dirname $dir)
        if test $dir = /
            break
        end
    end
    cd $dir
end
