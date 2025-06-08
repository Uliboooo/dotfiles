autoload -Uz compinit
compinit

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# brew git
export PATH=/opt/homebrew/bin/git:$PATH
export PATH=/opt/homebrew/bin/nano:$PATH

export PATH=$HOME/.cargo/bin/:$PATH
export PATH=$HOME/Library/Android/sdk/platform-tools/:$PATH

eval "$(starship init zsh)"

alias gitlog='git log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s"'
alias cdd='cd $HOME/Develop/'

alias nzenn='npx zenn new:article --title $1'
alias pzenn='npx preview'
