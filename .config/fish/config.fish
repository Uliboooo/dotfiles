# ╔═╗ ╔═╗ ╔╦╗ ╦ ╦              ╔═╗ ╔╗╔ ╦  ╦
# ╠═╝ ╠═╣  ║  ╠═╣      ──      ║╣  ║║║ ╚╗╔╝
# ╩   ╩ ╩  ╩  ╩ ╩              ╚═╝ ╝╚╝  ╚╝ 

if status is-interactive
    if not type -q fisher
      curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    end

    set -g fish_history_max 1000000

    set -l os (uname -s)
    if test "$os" = Darwin
        eval (/opt/homebrew/bin/brew shellenv)

        fish_add_path (brew --prefix coreutils)/libexec/gnubin
        fish_add_path (brew --prefix zip)/bin
        fish_add_path (brew --prefix unzip)/bin
        fish_add_path (brew --prefix gnu-sed)/libexec/gnubin
        fish_add_path /opt/homebrew/opt/llvm/bin
        fish_add_path /opt/homebrew/bin
        fish_add_path /opt/homebrew/opt/llvm@20/bin
        fish_add_path /Library/TeX/texbin

    else # run on linux
        if test -f /etc/os-release
            set DIST (string replace -r '^NAME=["\']?(.*)["\']?$' '$1' (grep '^NAME=' /etc/os-release))
        end

        fish_add_path /opt/rocm/bin
        fish_add_path $HOME/.local/bin/lap_tap
        set -gx LD_LIBRARY_PATH $LD_LIBRARY_PATH /opt/rocm/lib
        set -gx ROCM_PATH /opt/rocm

        set -gx HSA_OVERRIDE_GFX_VERSION 10.3.0
        set -gx OLLAMA_DEBUG 1
        set -gx OLLAMA_HOST 0.0.0.0:11434

        if set -q XDG_RUNTIME_DIR
            set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/keyring/ssh
        end
        set -gx LD_LIBRARY_PATH $LD_LIBRARY_PATH /opt/rocm/lib
        set -gx ROCM_PATH /opt/rocm

        set -U fish_ambiguous_case_sensitive
        set -gx EDITOR "nvim"

        if test -n $SSH_CONNECTION
          export TERM=xterm-256color
        end
    end

    # cargo
    fish_add_path $HOME/.cargo/bin
    # adb
    fish_add_path $HOME/Library/Android/sdk/platform-tools
    # lm studio
    fish_add_path $HOME/.lmstudio/bin
    # npm
    fish_add_path $HOME/.npm-global/bin
    # My tools
    fish_add_path $HOME/my_tools/bin
    # My apps
    fish_add_path $HOME/my_apps/bin
    # Moonbit
    fish_add_path $HOME/.moon/bin
    # Bun
    fish_add_path $HOME/.bun/bin

    if test -f "$HOME/.env"
        for line in (grep -v '^#' "$HOME/.env")
            set -l item (string split -m 1 '=' $line)
            set -gx $item[1] $item[2]
        end
    end

    # Gitステータス表示の有効化
    set -g __fish_git_prompt_show_informative_status 1
    set -g __fish_git_prompt_showdirtystate 1
    set -g __fish_git_prompt_showuntrackedfiles 1
    set -g __fish_git_prompt_showupstream informative
    set -g __fish_git_prompt_showcolorhints 1

    # 記号のカスタマイズ (お好みで)
    set -g __fish_git_prompt_char_dirtystate '*'
    set -g __fish_git_prompt_char_stagedstate '+'
    set -g __fish_git_prompt_char_untrackedfiles '…'
    set -g __fish_git_prompt_char_cleanstate '✔'

    # --- 環境変数 ---
    set -gx GTK_IM_MODULE fcitx
    set -gx QT_IM_MODULE fcitx
    set -gx XMODIFIERS @im=fcitx
    set -gx HYPRSHOT_DIR "$HOME/Pictures/Screenshots"
    set -g fish_greeting
end

# ╔═╗ ╔╗  ╔╗  ╦═╗
# ╠═╣ ╠╩╗ ╠╩╗ ╠╦╝
# ╩ ╩ ╚═╝ ╚═╝ ╩╚═

# ╔═╗ ╔╦╗       ╦ ╦  ╦ ╦  ╦ ╦
# ║    ║║      ╔╩╦╝ ╔╩╦╝ ╔╩╦╝
# ╚═╝ ═╩╝      ╩ ╩  ╩ ╩  ╩ ╩
abbr -a cdd 'cd $HOME/Develop'
abbr -a cdn 'cd $HOME/Documents/notes/'

# ╔═╗ ╦ ╔╦╗      ╔═╗ ╔╗  ╔╗  ╦═╗
# ║ ╦ ║  ║       ╠═╣ ╠╩╗ ╠╩╗ ╠╦╝
# ╚═╝ ╩  ╩       ╩ ╩ ╚═╝ ╚═╝ ╩╚═
abbr -a gst 'git status'
abbr -a gda 'git --no-pager diff'
abbr -a gln 'git            log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s"'
abbr -a gla 'git --no-pager log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s"'
abbr -a gls 'git --no-pager log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s" -n 15'
abbr -a gf  'git fetch'
abbr -a ghp 'echo "restore only a portion of the data."'
abbr -a gbs 'git switch'
abbr -a gbc 'git switch -c'
abbr -a gb  'git branch'

function gc
  git add .
  git commit -m "$argv[1]"
end

function grn -d "diff names between local and remote"
  set -l git_st (git branch --show-current)
  set -l remote_name (git remote)
  git diff --name-only "$git_st" "$remote_name/$git_st"
end

function grd -d "diff between local and remote"
  set -l git_st (git branch --show-current)
  set -l remote_name (git remote)
  git diff "$git_st" "$remote_name/$git_st"
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

# ╦ ╦ ╔╦╗ ╦ ╦   ╔═╗
# ║ ║  ║  ║ ║   ╚═╗
# ╚═╝  ╩  ╩ ╩═╝ ╚═╝

abbr -a lss      'ls -l'
abbr -a ff       'fastfetch'
abbr -a ls       'eza -l --icons=always'
abbr -a glist    '/bin/ls'
abbr -a printimg 'chafa -f kitty'
abbr -a cow      'cowsay'
abbr -a mi       'mediainfo'

abbr -a y        'yazi'
abbr -a :q       'exit'
abbr -a :Q       'exit'
abbr -a :wq      'exit'
abbr -a :Wq      'exit'

abbr -a rg       'rg --hidden'

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

abbr -a nv       'nvim'
abbr -a nvd      'nvim .'
abbr -a nnv      'nightly_nvim'
abbr -a nnvd     'nightly_nvim .'

abbr -a tl       'tmux ls'
abbr -a tmr      'tmux kill-session -t'

abbr -a rtss     'rts -cli | jq -r ".list[] | \"title: \\(.title)\\nlink: \\(.link)\\n\""'

function ta --description 'Attach or create a tmux session'
    if count $argv >/dev/null
        tmux new-session -A -s $argv[1]
    else
        tmux
        fi
    end
end

# ╔═╗ ╔═╗ ╦═╗ ╔═╗ ╔═╗       ╔      ╔═╗ ╦   ╔═╗ ╔╗╔ ╔═╗
# ║   ╠═╣ ╠╦╝ ║ ╦ ║ ║      ╔╝      ║   ║   ╠═╣ ║║║ ║ ╦
# ╚═╝ ╩ ╩ ╩╚═ ╚═╝ ╚═╝      ╝       ╚═╝ ╩═╝ ╩ ╩ ╝╚╝ ╚═╝

abbr -a cb 'cargo build'
abbr -a cr 'cargo run'
abbr -a cf 'cargo fmt'
abbr -a ch 'cargo check'

abbr -a cpr 'clang++ main.cpp -o out && ./out'

# ╔╦╗ ╔═╗ ╔═╗ ╔╗╔ ╔╗  ╦ ╔╦╗
# ║║║ ║ ║ ║ ║ ║║║ ╠╩╗ ║  ║
# ╩ ╩ ╚═╝ ╚═╝ ╝╚╝ ╚═╝ ╩  ╩

abbr -a mb 'moon build'
abbr -a mr 'moon run'
abbr -a mf 'moon fmt'
abbr -a mh 'moon check'

# ╔═╗ ╔═╗    ╔╦╗ ╔═╗ ╔═╗ ╔═╗      ╔═╗ ╔╗  ╔╗  ╦═╗
# ║ ║ ╚═╗ ──  ║║ ║╣  ╠═╝ ╚═╗      ╠═╣ ╠╩╗ ╠╩╗ ╠╦╝
# ╚═╝ ╚═╝    ═╩╝ ╚═╝ ╩   ╚═╝      ╩ ╩ ╚═╝ ╚═╝ ╩╚═

if string match -q '*Darwin*' (uname)
    abbr -a copy pbcopy
else
    abbr -a copy wl-copy
    abbr -a c    wl-copy
    abbr -a cc   clang
    abbr -a ccc  clang++
    abbr -a reboot 'systemctl reboot'
end

