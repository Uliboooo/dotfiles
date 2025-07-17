HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000 # HISTFILESIZEと同じ値、またはそれ以下に設定

# 履歴の追加・共有オプション
setopt APPEND_HISTORY     # シェル終了時に履歴を追加する（上書きではなく）
setopt INC_APPEND_HISTORY # コマンド入力後すぐに履歴ファイルに書き込む
setopt SHARE_HISTORY      # 複数のセッションで履歴を共有する
setopt HIST_SAVE_NO_DUPS

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

# [ -f "$HOME/.api_keys" ] && source "$HOME/.api_keys"

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
alias cdb='cd $HOME/Library/Mobile\ Documents/iCloud~md~obsidian/Documents'

alias nzenn='npx zenn new:article --title $1'
alias pzenn='npx zenn preview --open'

# run c program
alias crun='clang $1 && ./a.out'
alias cprun='clang++ main.c && ./a.out'

alias helpme='glow $HOME/dotfiles/zsh/README.md'

alias ff='fastfetch'

alias g='git'
alias gd='git diff'
alias gl='git log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s"'
alias gla='git --no-pager log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s"'
alias gsc='git switch -c $1'
alias gsw='git switch $1'
alias gst='git status'
alias gaa='git add .'
alias ga='git add $1'
alias gf='git fetch'
alias gb='git branch'

alias cf='cargo fmt'
alias ch='cargo check'

alias t='tmux'
alias nv='nvim'
alias em='emacs -nw'

alias ggw='/Users/yuki/Desktop/target/release/ghost_git_writer'

function gc() {
    echo "commit message: $1"
  git add .
  git commit -m "$1"
}

export $(grep -v '^#' $HOME/.env | xargs)
export OPENSSL_DIR="$(brew --prefix openssl@3)"
export PKG_CONFIG_PATH="$OPENSSL_DIR/lib/pkgconfig"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/yuki/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
