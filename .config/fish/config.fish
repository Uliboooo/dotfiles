# ╔═╗ ╔═╗ ╔╦╗ ╦ ╦              ╔═╗ ╔╗╔ ╦  ╦
# ╠═╝ ╠═╣  ║  ╠═╣      ──      ║╣  ║║║ ╚╗╔╝
# ╩   ╩ ╩  ╩  ╩ ╩              ╚═╝ ╝╚╝  ╚╝

if status is-interactive
    if not type -q fisher
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    end

    fish_config theme choose "Rosé Pine Moon"

    set -g fish_history_max 1000000
    set -g fish_greeting
    set -U fish_ambiguous_case_sensitive

    # direnv
    if type -q direnv
        direnv hook fish | source
    end
end

# ╔═╗ ╔═╗ ╔╦╗ ╦ ╦
# ╠═╝ ╠═╣  ║  ╠═╣
# ╩   ╩ ╩  ╩  ╩ ╩

# cargo
fish_add_path -g $HOME/.cargo/bin
# adb
fish_add_path -g $HOME/Library/Android/sdk/platform-tools
# My tools / apps
fish_add_path -g $HOME/my_tools/bin $HOME/my_apps/bin
# Moonbit
fish_add_path -g $HOME/.moon/bin
# copilot
fish_add_path -g $HOME/.local/bin
# go bin
if type -q go
    fish_add_path -g (go env GOPATH)/bin
end

if test (uname -s) = Darwin
    # Tex
    fish_add_path -g /Library/TeX/texbin
    fish_add_path -g $HOME/.bun/bin
    # LM Studio CLI (lms)
    fish_add_path -g $HOME/.lmstudio/bin

    if test -x /opt/homebrew/bin/brew
        /opt/homebrew/bin/brew shellenv | source
    end

    abbr -a copy pbcopy
    alias vmrun '/Applications/VMware Fusion.app/Contents/Library/vmrun'
else
    # Linux
    fish_add_path -g /opt/rocm/bin
    fish_add_path -g $HOME/.local/bin/lap_tap
    set -gx LD_LIBRARY_PATH $LD_LIBRARY_PATH /opt/rocm/lib
    set -gx ROCM_PATH /opt/rocm
    set -gx HSA_OVERRIDE_GFX_VERSION 10.3.0
    set -gx OLLAMA_DEBUG 1
    set -gx OLLAMA_HOST 0.0.0.0:11434
    set -gx LIBVIRT_DEFAULT_URI qemu:///system
    # home-manager が zsh には session vars で渡している分 (fish は HM 非管理)
    set -gx CC clang
    set -gx CXX clang++
    set -gx LD lld
    # npm
    fish_add_path -g $HOME/.npm-global/bin
    fish_add_path -g $HOME/.cache/.bun/bin

    if test -n "$SSH_CONNECTION"
        set -gx TERM xterm-256color
    end

    abbr -a copy wl-copy
end

# ╔═╗ ╔╗╔ ╦  ╦
# ║╣  ║║║ ╚╗╔╝
# ╚═╝ ╝╚╝  ╚╝

set -gx GTK_IM_MODULE fcitx
set -gx QT_IM_MODULE fcitx
set -gx XMODIFIERS @im=fcitx
set -gx HYPRSHOT_DIR "$HOME/Desktop/"

set -gx EDITOR nvim
set -gx SSH_ASKPASS_REQUIRE never
set -gx SSH_ASKPASS ""

# home-manager が zsh には session vars で渡している分 (fish は HM 非管理)
set -gx NPM_CONFIG_PREFIX $HOME/.npm-global
set -gx BUN_INSTALL $HOME/.cache/.bun

if test -f "$HOME/.env"
    for line in (grep -v '^#' "$HOME/.env")
        set -l item (string split -m 1 '=' $line)
        test -n "$item[1]"; and set -gx $item[1] $item[2]
    end
end

# ╔═╗ ╔╗  ╔╗  ╦═╗
# ╠═╣ ╠╩╗ ╠╩╗ ╠╦╝
# ╩ ╩ ╚═╝ ╚═╝ ╩╚═

# ╔═╗ ╔╦╗       ╦ ╦  ╦ ╦  ╦ ╦
# ║    ║║      ╔╩╦╝ ╔╩╦╝ ╔╩╦╝
# ╚═╝ ═╩╝      ╩ ╩  ╩ ╩  ╩ ╩
abbr -a cdd 'cd $HOME/Develop'
abbr -a cdn 'cd $HOME/Documents/notes/'
abbr -a cdr 'cd $HOME/Recent/'
abbr -a g "cd (ghq root)/(ghq list | fzf --preview 'ls (ghq root)/{}')"

# ╔═╗ ╦ ╔╦╗      ╔═╗ ╔╗  ╔╗  ╦═╗
# ║ ╦ ║  ║       ╠═╣ ╠╩╗ ╠╩╗ ╠╦╝
# ╚═╝ ╩  ╩       ╩ ╩ ╚═╝ ╚═╝ ╩╚═
abbr -a gst 'git status'
abbr -a gda 'git --no-pager diff'
abbr -a gln "git            log --all --date-order --date=format:'%y-%m-%d %H:%M' --graph --format=' <%h> %ad [%an] %C(green)%d%Creset %s'"
abbr -a gla "git --no-pager log --all --date-order --date=format:'%y-%m-%d %H:%M' --graph --format=' <%h> %ad [%an] %C(green)%d%Creset %s'"
abbr -a gls "git --no-pager log --all --date-order --date=format:'%y-%m-%d %H:%M' --graph --format=' <%h> %ad [%an] %C(green)%d%Creset %s' -n 15"
abbr -a gf 'git fetch'
abbr -a ghp "echo 'restore only a portion of the data.'"
abbr -a gbs 'git switch'
abbr -a gbc 'git switch -c'
abbr -a gb 'git branch'

function gc
    git add .
    git commit -m "$argv[1]"
end

function grn -d "diff names between local and remote"
    set -l branch (git branch --show-current)
    set -l remote (git remote)
    git diff --name-only "$branch" "$remote/$branch"
end

function grd -d "diff between local and remote"
    set -l branch (git branch --show-current)
    set -l remote (git remote)
    git diff "$branch" "$remote/$branch"
end

function githelp
    set -l help_md "$HOME/dotfiles/.config/fish/help-git.md"
    if type -q glow
        glow "$help_md"
    else if type -q bat
        bat "$help_md"
    else
        cat "$help_md"
    end
end

# ╦ ╦ ╔╦╗ ╦ ╦   ╔═╗
# ║ ║  ║  ║ ║   ╚═╗
# ╚═╝  ╩  ╩ ╩═╝ ╚═╝
abbr -a lss 'ls -l'
abbr -a ls 'eza --icons=always -l'
abbr -a glist '/bin/ls'
abbr -a printimg 'chafa -f kitty'
abbr -a cow 'cowsay'
abbr -a mi 'mediainfo'
abbr -a nv 'nvim'
abbr -a n 'nvim .'
abbr -a e 'emacs -nw .'
abbr -a nnv 'nightly_nvim'
abbr -a nnvd 'nightly_nvim .'
abbr -a tl 'tmux ls'
abbr -a tmr 'tmux kill-session -t'
abbr -a rtss 'rts -cli | jq -r ".list[] | \"title: \\(.title)\\nlink: \\(.link)\\n\""'
abbr -a rg 'rg --hidden'
abbr -a fd 'fd'

abbr -a y 'yazi'
abbr -a l 'lazygit'

abbr -a hxd 'hx .'
abbr -a h 'hx .'
abbr -a w '$EDITOR ~/work.md'

abbr -a update 'yay -Syu --noconfirm'

abbr -a :q 'exit'
abbr -a :Q 'exit'
abbr -a :wq 'exit'
abbr -a :Wq 'exit'

abbr -a reboot 'systemctl reboot'

function refish
    source $HOME/dotfiles/.config/fish/config.fish
    echo "refreshed fish config."
end

function hist
    history search --contains "$argv[1]"
end

function toup
    mkdir -p (dirname "$argv[1]") && touch "$argv[1]"
end

function ta --description 'Attach or create a tmux session'
    if test -n "$argv[1]"
        tmux new-session -A -s $argv[1]
    else
        tmux
    end
end

function distro
    if test -f /etc/os-release
        grep '^NAME=' /etc/os-release | sed 's/NAME=//; s/"//g'
    else
        echo "Unknown"
    end
end

function gg
    set -l dir (fd . "$HOME/Develop" --max-depth 1 --type d |
        sed "s|$HOME/Develop/||" |
        fzf --preview 'eza "$HOME/Develop/{}"')

    test -n "$dir"; and cd "$HOME/Develop/$dir"
end

function nsh
    set -l file (
        fd --type f -0 . |
        xargs -0 stat --format "%Y %n" |
        sort -rn |
        cut -d " " -f2- |
        fzf
    )

    test -n "$file"; and nvim "$file"
end

function yy
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    set -l cwd (cat -- "$tmp")
    if test -n "$cwd"; and test "$cwd" != "$PWD"
        cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

function wifi
    nmcli device wifi rescan 2>/dev/null
    sleep 1
    set -l saved (nmcli -g NAME connection show)

    set -l ssid (nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID device wifi list |
        awk -F: -v saved="$(string join \n $saved)" '
          BEGIN { n=split(saved, a, "\n"); for(i=1;i<=n;i++) s[a[i]]=1 }
          NF>=4 && $4!="" && !seen[$4]++ {
            cur  = ($1 == "*") ? "▶" : " "
            mark = ($4 in s)   ? "*" : " "
            printf "%s%s %3s%%  %-10s %s\n", cur, mark, $2, $3, $4
          }' |
        sort -k2 -rn |
        fzf --layout=reverse --border --prompt="Wi-Fi > " --header="▶ = connected, * = saved" |
        sed 's/^.\{2\} *[0-9]*% *[^ ]* *//')

    test -n "$ssid"; and nmcli device wifi connect "$ssid" --ask
end

function ff --description 'fastfetch alias'
    if set -q TERM_BACKGROUND; and test "$TERM_BACKGROUND" = light
        fastfetch --config ~/dotfiles/.config/fastfetch/light.jsonc
    else
        fastfetch --config ~/dotfiles/.config/fastfetch/config.jsonc
    end
end

# ╔═╗ ╔═╗ ╦═╗ ╔═╗ ╔═╗       ╔      ╔═╗ ╦   ╔═╗ ╔╗╔ ╔═╗
# ║   ╠═╣ ╠╦╝ ║ ╦ ║ ║      ╔╝      ║   ║   ╠═╣ ║║║ ║ ╦
# ╚═╝ ╩ ╩ ╩╚═ ╚═╝ ╚═╝      ╝       ╚═╝ ╩═╝ ╩ ╩ ╝╚╝ ╚═╝

abbr -a cb 'cargo build'
abbr -a cr 'cargo run'
abbr -a cf 'cargo fmt'
abbr -a ch 'cargo check'
abbr -a cn 'cp ~/dotfiles/rust_dev_temp/flake.nix ./flake.nix && ls ./flake.nix'

abbr -a cpr 'clang++ main.cpp -o out && ./out'

# ╔╦╗ ╔═╗ ╔═╗ ╔╗╔ ╔╗  ╦ ╔╦╗
# ║║║ ║ ║ ║ ║ ║║║ ╠╩╗ ║  ║
# ╩ ╩ ╚═╝ ╚═╝ ╝╚╝ ╚═╝ ╩  ╩

abbr -a mb 'moon build'
abbr -a mr 'moon run'
abbr -a mf 'moon fmt'
abbr -a mh 'moon check'

# ╔╗╔ ╦ ═╗ ╦
# ║║║ ║ ╔╩╦╝
# ╝╚╝ ╩ ╩ ╚═

abbr -a nd 'nix develop -c $SHELL'
abbr -a nbuild 'sudo nixos-rebuild switch --flake .#desktop'
abbr -a nupdate 'nix flake update'

function rebuild
    if test (uname -s) = Darwin
        echo "sudo darwin-rebuild switch --flake $HOME/dotfiles#macbook"
        sudo darwin-rebuild switch --flake $HOME/dotfiles#macbook
    else if test -f /etc/NIXOS
        echo "sudo nixos-rebuild switch --flake .#desktop"
        sudo nixos-rebuild switch --flake .#desktop
    else
        echo "home-manager switch --flake .#seli"
        home-manager switch --flake .#seli
    end
end

function fcp
    set -l name
    switch "$argv[1]"
        case '*rust*'
            echo "copy rust flake.nix"
            set name rust.nix
        case '*nim*'
            echo "copy nim flake.nix"
            set name nim.nix
        case '*gleam*'
            echo "copy gleam flake.nix"
            set name gleam.nix
        case '*typst*'
            echo "copy typst flake.nix"
            set name typst.nix
        case '*astro*'
            echo "copy astro flake.nix"
            set name bun_astro_vscode_lsp.nix
        case '*bun*'
            echo "copy bun flake.nix"
            set name bun_ts_flake.nix
        case '*'
            echo "unknown template: $argv[1]"
            return 1
    end

    cp "$HOME/dotfiles/flake_templates/$name" "$PWD/flake.nix"
    and git init
    and git add flake.nix
    and echo "use flake" >.envrc
    and echo ".direnv/" >>.gitignore
    and direnv allow
end
