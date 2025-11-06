# zmodload zsh/zprof

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

# setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_SAVE_NO_DUPS
setopt EXTENDED_HISTORY

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
# clangd
# export PATH="$(brew --prefix llvm)/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm@20/bin:$PATH"
# export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

# my tools
export PATH="$HOME/my_tools/:$PATH"

# if ((IS_LINUX)); then
#     source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
#     source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# else
#     source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
#     source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# fi

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(starship init zsh)"

ZSH_DIR="${HOME}/dotfiles/usr/zsh"

if [ -d $ZSH_DIR ] && [ -r $ZSH_DIR ] && [ -x $ZSH_DIR ]; then
    for f in ${ZSH_DIR}/**/*.zsh; do
        [ -r $f ] && source $f
    done
fi

export $(grep -v '^#' $HOME/.env | xargs)
export OPENSSL_DIR="$(brew --prefix openssl@3)"
export PKG_CONFIG_PATH="$OPENSSL_DIR/lib/pkgconfig"

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
# fpath=(${HOME}/.docker/completions $fpath)
# autoload -Uz compinit
# compinit
# End of Docker CLI completions

# Added by LM Studio CLI (lms)
# export PATH="$PATH:/Users/yuki/.lmstudio/bin"
# End of LM Studio CLI section


if ((IS_LINUX)); then
    export PATH=$PATH:/opt/rocm/bin
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rocm/lib
    export ROCM_PATH=/opt/rocm

    export HSA_OVERRIDE_GFX_VERSION=10.3.0
    export OLLAMA_DEBUG=1
    export OLLAMA_HOST=0.0.0.0:11434
fi

# eval $(opam env)

# zprof
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

