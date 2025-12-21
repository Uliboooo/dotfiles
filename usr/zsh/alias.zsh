alias cdd='cd $HOME/Develop/'
alias cdn='cd $HOME/Documents/notes && nvd'
# alias cdb='cd $HOME/Library/Mobile\ Documents/iCloud~md~obsidian/Documents'
# alias cdz='cd $HOME/Documents/zenn_content/'
# alias cdc='cd $HOME/Library/Mobile\ Documents/com\~apple\~CloudDocs/'
# alias cdn='cd $HOME/Library/Mobile\ Documents/com\~apple\~TextEdit/Documents'
# alias cdn='cd $HOME/Library/Mobile\ Documents/com\~apple\~CloudDocs/notes'
# alias nz='cdz && npx zenn new:article --title'
# alias cdt='cd $HOME/Library/Mobile\ Documents/com\~apple\~TextEdit/Documents'

alias nzenn='npx zenn new:article --title $1'
alias pzenn='npx zenn preview --open'

alias hxd='hx .'
if [ "$OS_NAME" = "Linux" ]; then
    alias hx='helix'
    alias hxd='helix .'
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

alias cf='cargo fmt'
alias ch='cargo check'
alias cr='cargo run'
alias cb='cargo build'
alias cbrm='cargo build --release && cargo build --release --target x86_64-unknown-linux-gnu && cargo build --release --target x86_64-pc-windows-gnu'

function note() {
    nvim $HOME/Library/Mobile\ Documents/com\~apple\~CloudDocs/note
}

alias tl='tmux ls'

function ta() { # attach tmux with name
    if [[ "$#" -gt 0 ]]; then
        tmux new-session -A -s "$1"
    else
        tmux
    fi
}
function tr() { # kill tmux sesstion
    if [[ "$#" -gt 0 ]]; then
        exit
    else
        tmux kill-session -t "$1"
    fi
}

alias nv='nvim'
alias nvd='nvim .'

alias em='emacsclient -t'
alias emacs='emacs -nw'
alias reload_em='launchctl unload ~/Library/LaunchAgents/org.emacs.daemon.plist && launchctl load ~/Library/LaunchAgents/org.emacs.daemon.plist && launchctl list | rg emacs'

alias r='rlwrap'

function distro() {
    cat /etc/os-release | rg '^NAME=' | rg '^NAME=".*"'
}

if ((IS_LINUX)); then
    if [[ $(distro) == *"Fedora"* ]]; then
        alias update='sudo dnf update -y && brew update && brew upgrade && rustup update'
    else
        alias update='sudo pacman -Syu --noconfirm && brew update && brew upgrade && rustup update && yay -Syu --noconfirm'
    fi
else
    alias update='brew update && brew upgrade && rustup update'
fi

alias rl='rlwrap sbcl'

function gc() {
  git add .
  git commit -m "$1"
}

function r2g() {
  ffmpeg -i "$1" -r 20 "$2"
}

alias cow='cowsay'

if ((IS_LINUX)); then
  alias copy='wl-copy'
else
  alias copy='pbcopy'
fi

function touch-p() {
    mkdir -p $(dirname "$1") && touch "$1"
}

alias cppr='clang++ main.cpp -o out && ./out'
alias alias-edit='nvim $HOME/dotfiles/usr/zsh/alias.zsh'
alias ls='eza'
alias f-l='rg "function" $HOME/dotfiles/usr/zsh/alias.zsh'
alias load_z='source ~/.zshrc'

alias li='limactl'
alias lili='limactl list'

# ocaml
alias 'ocf'='ocamlformat --enable-outside-detected-project -i'
alias 'oc'='ocaml'

alias vm='sh ~/dotfiles/vm-run.sh'
alias glist='/bin/ls'

alias help-vm='glow $HOME/dotfiles/help_vmrun.md'
alias rtss='rts -cli | jq -r ".list[] | \"title: \\(.title)\\nlink: \\(.link)\\n\""'
