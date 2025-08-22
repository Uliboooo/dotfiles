HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000 # HISTFILESIZEと同じ値、またはそれ以下に設定

setopt APPEND_HISTORY     # シェル終了時に履歴を追加する（上書きではなく）
setopt INC_APPEND_HISTORY # コマンド入力後すぐに履歴ファイルに書き込む
setopt SHARE_HISTORY      # 複数のセッションで履歴を共有する
setopt HIST_SAVE_NO_DUPS

OS_NAME=$(uname -s)
IS_LINUX=0

if [ "$OS_NAME" = "Linux" ]; then
    IS_LINUX=1
else
    IS_LINUX=0
fi

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
    export PATH=$(brew --prefix gnu-sed)/libexec/gnubin:$PATH
    export PATH=/opt/homebrew/bin:$PATH
fi

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
#myapps
export PATH=$HOME/my_apps/bin:$PATH

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(starship init zsh)"
eval "$(opam env)"

alias cdd='cd $HOME/Develop/'
alias cdb='cd $HOME/Library/Mobile\ Documents/iCloud~md~obsidian/Documents'
alias cdz='cd $HOME/Documents/zenn_content/'
alias nz='cdz && npx zenn new:article --title'

alias nzenn='npx zenn new:article --title $1'
alias pzenn='npx zenn preview --open'

if [ "$OS_NAME" = "Linux" ]; then
    alias hx='helix'
fi
alias hxd='hx .'

alias helpme='glow $HOME/dotfiles/alias_README.md'

alias ff='fastfetch'
alias ea='eza'
alias et='exit'

alias g='git'
alias gd='git diff'
alias gda='git --no-pager diff'
alias gl='git log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s"'
alias gla='git --no-pager log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s"'
alias gsc='git switch -c $1'
alias gsw='git switch $1'
alias gst='git status'
alias gaa='git add .'
alias ga='git add'
alias gf='git fetch'
alias gb='git branch'

alias cf='cargo fmt'
alias ch='cargo check'
alias cr='cargo run'
alias cb='cargo build'
alias cbrm='cargo build --release && cargo build --release --target x86_64-unknown-linux-gnu && cargo build --release --target x86_64-pc-windows-gnu'

function note() {
  nv  ~/Library/Mobile\ Documents/iCloud\~md\~obsidian/Documents/note
}

alias tl='tmux ls'
# new tumx
function t() {
    if [[ "$#" -gt 0 ]]; then
        tmux new -s "$1"
    else
        tmux
    fi
}
# attach tmux
function ta() {
    if [[ "$#" -gt 0 ]]; then
        tmux a -t "$1"
    else
        tmux a
    fi
}
# kill tmux sesstion
function tr() {
    if [[ "$#" -gt 0 ]]; then
        exit
    else
        tmux kill-session -t "$1"
    fi
}

alias nv='nvim'
alias nvd='nvim .'
# alias em='emacs -nw'
alias em='emacsclient -t'
alias reload_em='launchctl unload ~/Library/LaunchAgents/gnu.emacs.daemon.plist && launchctl load ~/Library/LaunchAgents/gnu.emacs.daemon.plist && launchctl list | grep emacs'
alias r='rlwrap'

alias update='sudo pacman -Syu --noconfirm && brew update && brew upgrade && rustup update'

alias sbcl='rlwrap sbcl'

function gc() {
    echo "commit message: $1"
  git add .
  git commit -m "$1"
}

function r2g() {
  ffmpeg -i "$1" -r 20 "$2"
}

function bsii() {
    if brew search "$1" | grep -q "$1"; then
        brew info "$1"
        read "?install? (y/n): " answer
        if [[ "$answer" == [yY] ]]; then
            brew install "$1"
        else
            return 1
        fi
    else
        return 1
    fi
}


export $(grep -v '^#' $HOME/.env | xargs)
export OPENSSL_DIR="$(brew --prefix openssl@3)"
export PKG_CONFIG_PATH="$OPENSSL_DIR/lib/pkgconfig"

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/yuki/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/yuki/.lmstudio/bin"
# End of LM Studio CLI section


if ((IS_LINUX)); then
    export PATH=$PATH:/opt/rocm/bin
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rocm/lib
    export ROCM_PATH=/opt/rocm

    export HSA_OVERRIDE_GFX_VERSION=10.3.0
    export OLLAMA_DEBUG=1 
    export OLLAMA_HOST=0.0.0.0:11434
fi
