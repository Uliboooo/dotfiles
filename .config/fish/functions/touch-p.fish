function touch-p --description 'Create directory and touch file'
    mkdir -p (dirname $argv[1])
    and touch $argv[1]
end
