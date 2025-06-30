SAVEHOST=50000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

OS_NAME=$(uname -s)
if [ "$OS_NAME" = "Linux" ]; then
    # eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    if [ -d "$HOME/.linuxbrew" ]; then
        eval "$($HOME/.linuxbrew/bin/brew shellenv)"
    elif [ -d "/home/linuxbrew/.linuxbrew" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
elif [ "$OS_NAME" = "Darwin" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH=$(brew --prefix coreutils)/libexec/gnubin:$PATH
    export PATH=$(brew --prefix zip)/bin:$PATH
    export PATH=$(brew --prefix unzip)/bin:$PATH
    export PATH=/opt/homebrew/bin:$PATH
fi

[ -f "$HOME/.api_keys" ] && source "$HOME/.api_keys"

# cargo
export PATH=$HOME/.cargo/bin/:$PATH
# adb
export PATH=$HOME/Library/Android/sdk/platform-tools/:$PATH
# lm studio
export PATH="$HOME/.lmstudio/bin/:$PATH"
# Tex
export PATH="/Library/TeX/texbin/:$PATH"
# npm
export PATH=$HOME/.npm-global/bin:$PATH

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(starship init zsh)"

alias cdd='cd $HOME/Develop/'

alias nzenn='npx zenn new:article --title $1'
alias pzenn='npx zenn preview --open'

# run c program
alias crun='clang $1 && ./a.out'
alias cprun='clang++ main.c && ./a.out'

alias helpme='glow $HOME/dotfiles/zsh/README.md'

alias g='git'
alias gd='git diff'
alias gl='git log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s"'

alias t='tmux'
alias nv='nvim'

function gc() {
    echo "commit message: $1"
  git add .
  git commit -m "$1"
}

