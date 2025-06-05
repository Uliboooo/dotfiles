# 補完システムをロード
autoload -Uz compinit

# compinitのキャッシュファイルのパス
ZSH_COMPDUMP="$HOME/.zcompdump"

# compinitのキャッシュが本日中に生成されていない、
# または存在しない場合にのみ再生成する
if [[ ! -e "$ZSH_COMPDUMP" || "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' "$ZSH_COMPDUMP" 2>/dev/null)" ]]; then
    compinit
    # compauditでキャッシュが破損しているか確認し、破損していれば再生成
    # compaudit | xargs rm -f
    # compinit -C # 強制的に再生成する場合はこれ
else
    # キャッシュが存在し、本日のものならばキャッシュを利用して初期化
    compinit -C
fi

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# git
export PATH=/usr/local/bin/git:$PATH

#cargo
export PATH=$PATH:/$HOME/.cargo/bin

#adb
export PATH=$PATH:~/Library/Android/sdk/platform-tools

# nano
export EDITOR=/opt/homebrew/bin/nano

# my tool
export PATH=$PATH:$HOME/dotfiles/my_tools

# starship
eval "$(starship init zsh)"

alias gitlog='git log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s"'
alias cdd='cd ~/Develop'
alias newzenn='npx zenn new:article --title $1'
alias prezenn='npx zenn preview'

alias py='python3 $1'

alias helpme="echo -e "gitlog=git log graph\ncdd=cd ~/Develop\nnewzenn=new zenn article\npreview zenn""

# run c programm
alias crun='clang main.c && ./a.out'
alias cprun'clang++ main.c && ./a.out'

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(~/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# Added by LM Studio CLI (lms)
export PATH="$PATH:~/.lmstudio/bin"
# End of LM Studio CLI section

# vm alias
alias vm_run_ubuntu='vmrun -T fusion start "'~/Virtual Machines.localized/Ubuntu 64-bit Arm Server 24.04.2.vmwarevm/Ubuntu 64-bit Arm Server 24.04.2.vmx'" nogui'
alias vm_list='vmrun list'
alias vm_shutdown_ubuntu='vmrun -T fusion stop "'~/Virtual Machines.localized/Ubuntu 64-bit Arm Server 24.04.2.vmwarevm/Ubuntu 64-bit Arm Server 24.04.2.vmx'" soft'
alias vm_sus_ubuntu='vmrun -T fusion suspend "~/Virtual Machines.localized/Ubuntu 64-bit Arm Server 24.04.2.vmwarevm/Ubuntu 64-bit Arm Server 24.04.2.vmx"'

alias vm_commands='cat $HOME/dotfiles/vm_command/vm_command_help.md'

export PATH="/Library/TeX/texbin:$PATH"
