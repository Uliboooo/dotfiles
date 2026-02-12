# zmodload zsh/zprof

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

# setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_SAVE_NO_DUPS
setopt EXTENDED_HISTORY
setopt local_options nocasematch

OS_NAME=$(uname -s)
DIST=$(sed -n 's/^NAME=["'\'']\(.*\)["'\'']$/\1/p' /etc/os-release)

if [ "$OS_NAME" = "Darwin" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH=$(brew --prefix coreutils)/libexec/gnubin:$PATH
    export PATH=$(brew --prefix zip)/bin:$PATH
    export PATH=$(brew --prefix unzip)/bin:$PATH
    export PATH=$(brew --prefix gnu-sed)/libexec/gnubin:$PATH
    export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
    export PATH=/opt/homebrew/bin:$PATH

    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
else
    export PATH=$PATH:/opt/rocm/bin
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rocm/lib
    export ROCM_PATH=/opt/rocm

    export HSA_OVERRIDE_GFX_VERSION=10.3.0
    export OLLAMA_DEBUG=1
    export OLLAMA_HOST=0.0.0.0:11434

    export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/keyring/ssh

    if [[ "${DIST}" =~  "arch" ]]; then
        source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
        source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    else
        source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    fi
    [[ -f "/home/coyuki/.local/share/swiftly/env.sh" ]] && source "$HOME/.local/share/swiftly/env.sh"
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
# clangd
# export PATH="$(brew --prefix llvm)/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm@20/bin:$PATH"
# export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

# my tools
export PATH="$HOME/my_tools/:$PATH"


eval "$(starship init zsh)"

# load zsh files
ZSH_DIR="${HOME}/dotfiles/zsh"
if [ -d $ZSH_DIR ] && [ -r $ZSH_DIR ] && [ -x $ZSH_DIR ]; then
    for f in ${ZSH_DIR}/**/*.zsh; do
        [ -r $f ] && source $f
    done
fi

export $(grep -v '^#' $HOME/.env | xargs)

# zprof
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

export PATH="$HOME/my_apps/bin:$PATH"

autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# moonbit
export PATH="$HOME/.moon/bin:$PATH"

export HYPRSHOT_DIR="$HOME/Pictures/ScreenShots"


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/home/coyuki/.opam/opam-init/init.zsh' ]] || source '/home/coyuki/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration
