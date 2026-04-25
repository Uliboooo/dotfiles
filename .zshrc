# zmodload zsh/zprof

# History
HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
setopt PROMPT_SUBST

precmd_functions+=(set_last_status)
set_last_status() { _LAST_STATUS=$? }

git_prompt() {
  git rev-parse --is-inside-work-tree &>/dev/null || return

  local branch changed ahead behind

  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

  changed=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

  local upstream
  upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)
  if [[ -n "$upstream" ]]; then
    ahead=$(git rev-list "${upstream}..HEAD" 2>/dev/null | wc -l | tr -d ' ')
    behind=$(git rev-list "HEAD..${upstream}" 2>/dev/null | wc -l | tr -d ' ')
  else
    ahead=0
    behind=0
  fi

  local green=$'%F{green}'
  local red=$'%F{red}'
  local blue=$'%F{blue}'
  local yellow=$'%F{yellow}'
  local reset=$'%f'

  local status_icon
  if [[ $changed -eq 0 ]]; then
    status_icon="${green}✔${reset}"
  else
    status_icon="${red}✘${reset}"
  fi

  local remote_info=""
  if [[ $ahead -gt 0 ]] || [[ $behind -gt 0 ]]; then
    [[ $ahead -gt 0 ]] && remote_info="${remote_info}${yellow}↑${ahead}${reset}"
    [[ $behind -gt 0 ]] && remote_info="${remote_info}${yellow}↓${behind}${reset}"
    remote_info="|${remote_info}"
  fi

  echo "(${green}${branch}${reset}|${status_icon}${remote_info})"
}

face_prompt() {
  [[ $_LAST_STATUS -eq 0 ]] && echo '%B%F{green}:)%f%b' || echo '%B%F{red}:(%f%b'
}

remote_info() {
  if [[ -n "$SSH_CONNECTION" ]]; then
    echo "%F{yellow}%n@%m%f "
  fi
}

PROMPT='$(remote_info)%F{blue}%~%f $(git_prompt)
$(face_prompt) '

# if ! command -v yay &>/dev/null; then
#   sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
# fi


if ! command -v sheldon &>/dev/null; then
  echo "Installing sheldon..."
  ln -fs $HOME/dotfiles/.config/zsh-abbr ~/.config/zsh-abbr/
  ln -fs $HOME/dotfiles/.config/sheldon ~/.config/sheldon
  case "$OSTYPE" in
    linux*)  yay -Syu sheldon --noconfirm && echo "sheldon installed." || echo "faield install." ;;
    darwin*) brew install sheldon && echo "sheldon installed." || echo "faield install." ;;
    *)       echo "Σ(・ω・ノ)ノ" ;;
  esac
fi

# sheldon
eval "$(sheldon -q source)"
autoload -Uz compinit
compinit

# ==============================================================================
# PATH
# ==============================================================================

# cargo
export PATH="$HOME/.cargo/bin:$PATH"
# adb
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
# My tools / apps
export PATH="$HOME/my_tools/bin:$HOME/my_apps/bin:$PATH"
# Moonbit
export PATH="$HOME/.moon/bin:$PATH"
# Bun
export PATH="$HOME/.bun/bin:$PATH"
# copilot
export PATH="$HOME/.local/bin:$PATH"

if [[ "$(uname -s)" == "Darwin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
    export PATH="$(brew --prefix zip)/bin:$PATH"
    export PATH="$(brew --prefix unzip)/bin:$PATH"
    export PATH="$(brew --prefix gnu-sed)/libexec/gnubin:$PATH"
    export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
    export PATH="/opt/homebrew/bin:$PATH"
    # clangd (llvm@20)
    export PATH="/opt/homebrew/opt/llvm@20/bin:$PATH"
    # Tex
    export PATH="/Library/TeX/texbin:$PATH"
else
    # Linux
    export PATH="/opt/rocm/bin:$PATH"
    export PATH="$HOME/.local/bin/lap_tap:$PATH"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/rocm/lib"
    export ROCM_PATH=/opt/rocm
    export HSA_OVERRIDE_GFX_VERSION=10.3.0
    export OLLAMA_DEBUG=1
    export OLLAMA_HOST=0.0.0.0:11434
    export LIBVIRT_DEFAULT_URI=qemu:///system
    # npm
    export PATH="$HOME/.npm-global/bin:$PATH"

    if [[ -n "$XDG_RUNTIME_DIR" ]]; then
        export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/keyring/ssh"
    fi

    if [[ -n "$SSH_CONNECTION" ]]; then
      export TERM=xterm-256color
    fi

    # bun completions
    [ -s "/home/alice/.bun/_bun" ] && source "/home/alice/.bun/_bun"

    # moonbit
    export PATH="$HOME/.moon/bin:$PATH"
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

    alias copy='wl-copy'
fi

# ==============================================================================
# enviroments variables
# ==============================================================================

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export HYPRSHOT_DIR="$HOME/Pictures/Screenshots"

export EDITOR=nvim

# load .env
if [[ -f "$HOME/.env" ]]; then
    while IFS='=' read -r key value; do
        [[ "$key" =~ ^#.*$ ]] && continue
        [[ -z "$key" ]] && continue
        export "$key=$value"
    done < <(grep -v '^#' "$HOME/.env")
fi

# ==============================================================================
# functions
# ==============================================================================

# Git
function gc() {
    git add .
    git commit -m "$1"
}

function grn() {
    local branch=$(git branch --show-current)
    local remote=$(git remote)
    git diff --name-only "$branch" "$remote/$branch"
}

function grd() {
    local branch=$(git branch --show-current)
    local remote=$(git remote)
    git diff "$branch" "$remote/$branch"
}

function githelp() {
    local help_md="$HOME/dotfiles/.config/fish/help-git.md"
    if command -v glow &>/dev/null; then
        glow "$help_md"
    elif command -v bat &>/dev/null; then
        bat "$help_md"
    else
        cat "$help_md"
    fi
}

# utilitiy
function rezsh() {
    source "$HOME/.zshrc"
    echo "refreshed zsh config."
}

function hist() {
    history | grep "$1"
}

function toup() {
    mkdir -p "$(dirname "$1")" && touch "$1"
}

function ta() {
    if [[ -n "$1" ]]; then
        tmux new-session -A -s "$1"
    else
        tmux
    fi
}

function distro() {
    if [[ -f /etc/os-release ]]; then
        grep '^NAME=' /etc/os-release | sed 's/NAME=//; s/"//g'
    else
        echo "Unknown"
    fi
}

function ff() {
  if [[ "${TERM_BACKGROUND:-}" == "light" ]]; then
    fastfetch --config ~/dotfiles/.config/fastfetch/light.jsonc
  else
    fastfetch --config ~/dotfiles/.config/fastfetch/config.jsonc
  fi
}

function note() {
  cd ~/Documents/org/ && emacs -nw .
}

# zprof
