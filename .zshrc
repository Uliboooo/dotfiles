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

nix_shell_prompt() {
  if [[ -n "$IN_NIX_SHELL" ]]; then
    echo "%F{magenta}[nix:${IN_NIX_SHELL}]%f "
  fi
}

PROMPT='$(remote_info)%F{blue}%~%f $(nix_shell_prompt)$(git_prompt)
$(face_prompt) '

if ! command -v sheldon &>/dev/null; then
  echo "Installing sheldon..."
  ln -fs $HOME/dotfiles/.config/zsh-abbr ~/.config/zsh-abbr/
  ln -fs $HOME/dotfiles/.config/sheldon ~/.config/sheldon
  case "$OSTYPE" in
    linux*)  yay -Syu sheldon --noconfirm && echo "sheldon installed." || echo "faield install." ;;
    darwin*) echo "sheldon is missing. Install via nix/home-manager." ;;
    *)       echo "Σ(・ω・ノ)ノ" ;;
  esac
fi

# sheldon
eval "$(sheldon -q source)"

# complete
autoload -Uz compinit

() {
  # (#q..) は extended_glob 必須。無いと [[ -n .. ]] が常に真になりフルの
  # compinit を毎回引く。dump は compinit の既定と同じ $ZDOTDIR に置く。
  setopt local_options extended_glob
  local zcd="${ZDOTDIR:-$HOME}/.zcompdump"
  if [[ ! -f "$zcd" || -n ${~zcd}(#qN.mh+24) ]]; then
    compinit -d "$zcd"
  else
    compinit -C -d "$zcd"
  fi
}

# direnv
eval "$(direnv hook zsh)"

command -v tirith >/dev/null 2>&1 && eval "$(tirith init --shell zsh)"

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
# copilot
export PATH="$HOME/.local/bin:$PATH"
# go bin
export PATH="$PATH:$(go env GOPATH)/bin"

if [[ "$(uname -s)" == "Darwin" ]]; then
    # Tex
    export PATH="/Library/TeX/texbin:$PATH"
    export PATH="$HOME/.bun/bin:$PATH"
    
# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section

    eval "$(/opt/homebrew/bin/brew shellenv)"

    alias copy='pbcopy'
    alias vmrun='/Applications/VMware\ Fusion.app/Contents/Library/vmrun'
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
    export PATH="$HOME/.cache/.bun/bin:$PATH"

    # if [ -z "$SSH_AUTH_SOCK" ]; then
    #   eval "$(ssh-agent -s)" > /dev/null
    # fi

    # for KDE
    # export SSH_ASKPASS=/usr/bin/ksshaskpass
    # if ! pgrep -u "$USER" ssh-agent >/dev/null; then
    #   eval "$(ssh-agent -s)" >/dev/null
    # fi
    # export SSH_ASKPASS_REQUIRE=prefer

    if [[ -n "$SSH_CONNECTION" ]]; then
      export TERM=xterm-256color
    fi

    # bun completions
    [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

    # moonbit
    export PATH="$HOME/.moon/bin:$PATH"
    # export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

    alias copy='wl-copy'
fi

# ==============================================================================
# enviroments variables
# ==============================================================================

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export HYPRSHOT_DIR="$HOME/Desktop/"

export EDITOR=nvim
export SSH_ASKPASS_REQUIRE=never
export SSH_ASKPASS=""

# load .env
while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" == \#* ]] && continue
  export "$key=$value"
done < "$HOME/.env"

# ==============================================================================
# functions
# ==============================================================================
#

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

function g() {
  cd "$(ghq root)/$(ghq list | fzf --preview 'ls $(ghq root)/{}')"
}

function gg() {
	local dir

	dir=$(fd . "$HOME/Develop" --max-depth 1 --type d |
		sed "s|$HOME/Develop/||" |
		fzf --preview 'eza "$HOME/Develop/{}"')

	[[ -n $dir ]] && cd "$HOME/Develop/$dir"
}

function nsh() {
  local file

  file=$(
    fd --type f -0 . \
      | xargs -0 stat --format "%Y %n" \
      | sort -rn \
      | cut -d " " -f2- \
      | fzf
  ) || return

  [[ -n "$file" ]] && nvim "$file"
}

function yy() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

function rebuild() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "sudo darwin-rebuild switch --flake .#macbook"
    sudo darwin-rebuild switch --flake .#macbook
  elif [[ -f /etc/NIXOS ]]; then
    echo "sudo nixos-rebuild switch --flake .#desktop"
    sudo nixos-rebuild switch --flake .#desktop
  else
    echo "home-manager switch --flake .#seli"
    home-manager switch --flake .#seli
  fi
}

function fcp() {
  local name

  case $1 in
    *rust*)
      echo "copy rust flake.nix"
      name="rust.nix"
      ;;
    *nim*)
      echo "copy nim flake.nix"
      name="nim.nix"
      ;;
    *gleam*)
      echo "copy gleam flake.nix"
      name="gleam.nix"
      ;;
    *typst*)
      echo "copy typst flake.nix"
      name="typst.nix"
      ;;
    *astro*)
      echo "copy astro flake.nix"
      name="bun_astro_vscode_lsp.nix"
      ;;
    *bun*)
      echo "copy bun flake.nix"
      name="bun_ts_flake.nix"
      ;;
    *)
      echo "unknown template: $1"
      return 1
      ;;
  esac

  cp "$HOME/dotfiles/flake_templates/$name" "$PWD/flake.nix" \
  && git init \
  && git add flake.nix \
  && echo "use flake" > .envrc && echo ".direnv/" >> .gitignore \
  && direnv allow
}

function wifi() {
  nmcli device wifi rescan 2>/dev/null; sleep 1
  local saved ssid
  saved=$(nmcli -g NAME connection show)

  ssid=$(nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID device wifi list \
    | awk -F: -v saved="$saved" '
      BEGIN { n=split(saved, a, "\n"); for(i=1;i<=n;i++) s[a[i]]=1 }
      NF>=4 && $4!="" && !seen[$4]++ {
        cur  = ($1 == "*") ? "▶" : " "
        mark = ($4 in s)   ? "*" : " "
        printf "%s%s %3s%%  %-10s %s\n", cur, mark, $2, $3, $4
      }' \
    | sort -k2 -rn \
    | fzf --layout=reverse --border --prompt="Wi-Fi > " \ 
          --header="▶ = connected, * = saved" \
    | sed 's/^.\{2\} *[0-9]*% *[^ ]* *//')

  [ -n "$ssid" ] && nmcli device wifi connect "$ssid" --ask
}

# zprof
