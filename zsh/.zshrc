# zmodload zsh/zprof

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# brew
export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
# cargo
export PATH=$HOME/.cargo/bin/:$PATH
# adb
export PATH=$HOME/Library/Android/sdk/platform-tools/:$PATH
# lm studio
export PATH="$HOME/.lmstudio/bin/:$PATH"
# Tex
export PATH="/Library/TeX/texbin/:$PATH"


eval "$(starship init zsh)"

alias gitlog='git log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s"'
alias cdd='cd $HOME/Develop/'

alias nzenn='npx zenn new:article --title $1'
alias pzenn='npx zenn preview --open'

# run c program
alias crun='clang $1 && ./a.out'
alias cprun='clang++ main.c && ./a.out'

# zprof
