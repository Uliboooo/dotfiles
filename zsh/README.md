# alias


## formated git log
```
alias gitlog='git log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s"'

gitlog
```

## cd to Develop dir
```
alias cdd='cd $HOME/Develop/'
cdd
```

## create a new zenn article
```
alias nzenn='npx zenn new:article --title $1'

alias pzenn='npx zenn preview --open'
```

## build and run c program
```
alias crun='clang $1 && ./a.out'
crun main.c
```

## build and run cpp program
```
alias cprun='clang++ $1 && ./a.out'
cprun main.cpp
```

## show these alias
```
alias helpme='glow $HOME/dotfiles/zsh/README.md'
```

