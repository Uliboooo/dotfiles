# zmodload zsh/zprof

OS_NAME=$(uname -s)
if [ "$OS_NAME" = "Linux" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ "$OS_NAME" = "Darwin" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# brew gnu utiles
export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
# cargo
export PATH=$HOME/.cargo/bin/:$PATH
# adb
export PATH=$HOME/Library/Android/sdk/platform-tools/:$PATH
# lm studio
export PATH="$HOME/.lmstudio/bin/:$PATH"
# Tex
export PATH="/Library/TeX/texbin/:$PATH"

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(starship init zsh)"

alias gitlog='git log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s"'
alias cdd='cd $HOME/Develop/'

alias nzenn='npx zenn new:article --title $1'
alias pzenn='npx zenn preview --open'

# run c program
alias crun='clang $1 && ./a.out'
alias cprun='clang++ main.c && ./a.out'

alias helpme='glow $HOME/dotfiles/zsh/README.md'

# zprof
