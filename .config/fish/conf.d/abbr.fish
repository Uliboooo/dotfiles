# ---------------------------------------------------------------------
#       _                                  _ _
#   ___| |__   __ _ _ __   __ _  ___    __| (_)_ __
#  / __| '_ \ / _` | '_ \ / _` |/ _ \  / _` | | '__|
# | (__| | | | (_| | | | | (_| |  __/ | (_| | | |
#  \___|_| |_|\__,_|_| |_|\__, |\___|  \__,_|_|_|
#                         |___/
# ---------------------------------------------------------------------

abbr -a cdd 'cd $HOME/Develop'
abbr -a cdn 'cd $HOME/Documents/notes/'

# ---------------------------------------------------------------------
#        _ _           _ _
#   __ _(_) |_    __ _| (_) __ _ ___
#  / _` | | __|  / _` | | |/ _` / __|
# | (_| | | |_  | (_| | | | (_| \__ \
#  \__, |_|\__|  \__,_|_|_|\__,_|___/
#  |___/
# ---------------------------------------------------------------------

abbr -a gst 'git status'
abbr -a gda 'git --no-pager diff'
abbr -a gln 'git            log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s"'
abbr -a gla 'git --no-pager log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s"'
abbr -a gls 'git --no-pager log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s" -n 15'
abbr -a ghp 'echo "restora only a portion of the data."'

function gc
    git add .
    git commit -m "$argv[1]"
end

function githelp
    set -l help_md_path "$HOME/dotfiles/.config/fish/help-git.md"
    if type -q glow
        glow "$help_md_path"
    else if type -q bat
        bat "$help_md_path"
    else
        cat "$help_md_path"
    end
end

# ---------------------------------------------------------------------
#  _   _ _   _ _ _ _              __ __     ___                __
# | | | | |_(_) (_) |_ _   _     / / \ \   / (_)_ __ ___      / /
# | | | | __| | | | __| | | |   / /   \ \ / /| | '_ ` _ \    / /
# | |_| | |_| | | | |_| |_| |  / /     \ V / | | | | | | |  / /
#  \___/ \__|_|_|_|\__|\__, | /_/       \_/  |_|_| |_| |_| /_/
#                      |___/
#  _____
# |_   _| __ ___  _   ___  __
#   | || '_ ` _ \| | | \ \/ /
#   | || | | | | | |_| |>  <
#   |_||_| |_| |_|\__,_/_/\_\
# ---------------------------------------------------------------------

abbr -a lss 'ls -l'
abbr -a ff fastfetch
abbr -a ls 'eza -l'
abbr -a glist /bin/ls
abbr -a printimg 'chafa -f kitty'
abbr -a cow cowsay

function refish
  source $HOME/dotfiles/.config/fish/config.fish
  source $HOME/dotfiles/.config/fish/conf.d/abbr.fish &&
  echo "refreshed fish config."
end

function hist
    history search --contains "$argv[1]"
end

function toup
    mkdir -p (dirname "$argv[1]") && touch "$argv[1]"
end

abbr -a nv nvim
abbr -a nvd 'nvim .'

abbr -a tl 'tmux ls'
abbr -a tr 'tmux kill-session -t'

function ta --description 'Attach or create a tmux session'
    if count $argv >/dev/null
        tmux new-session -A -s $argv[1]
    else
        tmux
        fi
    end
end

# ---------------------------------------------------------------------
#   ____                           __   ____ _
#  / ___|__ _ _ __ __ _  ___      / /  / ___| | __ _ _ __   __ _
# | |   / _` | '__/ _` |/ _ \    / /  | |   | |/ _` | '_ \ / _` |
# | |__| (_| | | | (_| | (_) |  / /   | |___| | (_| | | | | (_| |
#  \____\__,_|_|  \__, |\___/  /_/     \____|_|\__,_|_| |_|\__, |
#                 |___/                                    |___/
# ---------------------------------------------------------------------

abbr -a cb 'cargo build'
abbr -a cr 'cargo run'
abbr -a cf 'cargo fmt'
abbr -a ch 'cargo check'

abbr -a cpr 'clang++ main.cpp -o out && ./out'

# ---------------------------------------------------------------------
#   ___  ____            _                           _            _
#  / _ \/ ___|        __| | ___ _ __   ___ _ __   __| | ___ _ __ | |_
# | | | \___ \ _____ / _` |/ _ \ '_ \ / _ \ '_ \ / _` |/ _ \ '_ \| __|
# | |_| |___) |_____| (_| |  __/ |_) |  __/ | | | (_| |  __/ | | | |_
#  \___/|____/       \__,_|\___| .__/ \___|_| |_|\__,_|\___|_| |_|\__|
#                              |_|
#        _ _
#   __ _| (_) __ _ ___  ___  ___
#  / _` | | |/ _` / __|/ _ \/ __|
# | (_| | | | (_| \__ \  __/\__ \
#  \__,_|_|_|\__,_|___/\___||___/
# ---------------------------------------------------------------------

function distro
    if test -f /etc/os-release
        grep '^NAME=' /etc/os-release | sed 's/NAME=//; s/"//g'
    else
        echo Unknown
    end
end

if string match -q '*Darwin*' (uname)
    abbr -a copy pbcopy
    abbr -a update 'brew update && brew upgrade && rustup update'
else
    abbr -a copy wl-copy
    abbr -a cc clang
    abbr -a ccc clang++
    abbr -a hx helix

    set distro_name (distro)
    if string match -qi '*Fedora*' $distro_name
        abbr -a update 'sudo dnf update -y && brew update && brew upgrade && rustup update'
    else
        abbr -a update 'yay -Syu --noconfirm'
    end
end
