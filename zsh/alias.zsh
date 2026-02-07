alias cdd='cd $HOME/Develop/'
alias cdn='cd $HOME/Documents/notes'

function distro() {
    cat /etc/os-release | rg '^NAME=' | rg '^NAME=".*"'
}

if [[ "$OSTYPE" == "darwin"* ]];then
  alias copy='pbcopy'
  alias update='brew update && brew upgrade && rustup update'
else
  alias copy='wl-copy'
  alias cc='clang'
  alias ccc='clang++'

  if [[ $(distro) == *"Fedora"* ]]; then
    alias update='sudo dnf update -y && brew update && brew upgrade && rustup update'
  else
    alias update='sudo pacman -Syu --noconfirm && brew update && brew upgrade && rustup update && yay -Syu --noconfirm'
  fi
fi


alias ff='fastfetch'

alias g='git'
alias gd='git diff'
alias gda='git --no-pager diff'
alias gdal='git -c diff.tool=meld --no-pager diff'
alias gl='git log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s"'
alias gls='gl -n 15'
alias gla='git --no-pager log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s"'
alias gbc='git switch -c $1'
alias gbs='git switch $1'
alias gst='git status'
alias gaa='git add .'
alias ga='git add'
alias gf='git fetch'
alias gb='git branch'
alias gdn='git diff --name-only'
alias gdan='git --no-pager diff --name-only'
function gc() {
  git add .
  git commit -m "$1"
}


alias cf='cargo fmt'
alias ch='cargo check'
alias cr='cargo run'
alias cb='cargo build'
alias cbrm='cargo build --release && cargo build --release --target x86_64-unknown-linux-gnu && cargo build --release --target x86_64-pc-windows-gnu'

alias tl='tmux ls'
alias tr='tmux kill-session -t'

alias hist=history

function ta() {
    if [[ "$#" -gt 0 ]]; then
        tmux new-session -A -s "$1"
    else
        tmux
    fi
}

alias cow='cowsay'

alias nv='nvim'
alias nvd='nvim .'
alias hxd='hx .'

alias cop='copilot --banner'
alias ppp='copilot -p'

alias r='rlwrap'
alias rl='rlwrap sbcl'

function r2g() {
  ffmpeg -i "$1" -r 20 "$2"
}

function touch-p() {
    mkdir -p $(dirname "$1") && touch "$1"
}

alias cppr='clang++ main.cpp -o out && ./out'
alias alias-edit='nvim $HOME/dotfiles/usr/zsh/alias.zsh'
alias ls='eza'
alias f-l='rg "function" $HOME/dotfiles/usr/zsh/alias.zsh'

alias glist='/bin/ls'

alias help-vm='glow $HOME/dotfiles/help_vmrun.md'
alias rtss='rts -cli | jq -r ".list[] | \"title: \\(.title)\\nlink: \\(.link)\\n\""'

alias printimg='chafa -f kitty'

function ghwatch() {
  local run_id
  run_id=$(gh run list | awk '$1=="*" { print $7; exit }')

  if [ -n "$run_id" ]; then
    gh run watch "$run_id"
  else
    echo "No active runs found."
  fi
}

