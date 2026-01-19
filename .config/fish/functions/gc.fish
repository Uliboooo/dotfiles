function gc --description 'Stage all changes and commit'
    git add .
    git commit -m "$argv[1]"
end
