set -gx fish_history_size 1000000
set -g fish_greeting (fortune)

fish_add_path $HOME/.cargo/bin $HOME/.npm-global/bin $HOME/my_apps/bin $HOME/.moon/bin

switch (uname)
    case Darwin
        # Homebrew (evalはコストがかかるため、必要なパスのみ追加でも可)
        if test -f /opt/homebrew/bin/brew
            eval (/opt/homebrew/bin/brew shellenv)
            fish_add_path (brew --prefix coreutils)/libexec/gnubin \
                          (brew --prefix zip)/bin \
                          (brew --prefix unzip)/bin \
                          (brew --prefix gnu-sed)/libexec/gnubin
        end
        fish_add_path /Library/TeX/texbin

    case Linux
        # ROCm / Ollama
        set -gx ROCM_PATH /opt/rocm
        fish_add_path $ROCM_PATH/bin
        set -gx LD_LIBRARY_PATH $LD_LIBRARY_PATH $ROCM_PATH/lib
        set -gx HSA_OVERRIDE_GFX_VERSION 10.3.0
        set -gx OLLAMA_DEBUG 1
        set -gx OLLAMA_HOST 0.0.0.0:11434

        # Hyprland / Input
        set -gx HYPRSHOT_DIR $HOME/Pictures/ScreenShots
        set -gx GTK_IM_MODULE fcitx
        set -gx QT_IM_MODULE fcitx
        set -gx XMODIFIERS @im=fcitx
end

# --- .env ファイルの読み込み ---
if test -f $HOME/.env
    for line in (cat $HOME/.env | grep -v '^#' | string trim)
        if test -n "$line"
            set -l kv (string split -m 1 = $line)
            if set -q kv[2]
                set -gx $kv[1] $kv[2]
            end
        end
    end
end

# --- Abbreviations (abbr) ---
abbr -a cdd 'cd $HOME/Develop/'
abbr -a cdn 'cd $HOME/Documents/notes'
abbr -a ls 'eza'
abbr -a ff 'fastfetch'
abbr -a cow 'cowsay'
abbr -a printimg 'chafa -f kitty'
abbr -a glist '/bin/ls'

# Editor
abbr -a nv 'nvim'
abbr -a nvd 'nvim .'
abbr -a hx 'helix'
abbr -a hxd 'hx .'
abbr -a em 'emacsclient -t'
abbr -a emacs 'emacs -nw'
abbr -a alias-edit "nvim ~/.config/fish/config.fish" # パスをfish用に変更

# Git
abbr -a g 'git'
abbr -a gd 'git diff'
abbr -a gda 'git --no-pager diff'
abbr -a gdal 'git -c diff.tool=meld --no-pager diff'
abbr -a gl 'git log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s"'
abbr -a gls 'git log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s" -n 15'
abbr -a gla 'git --no-pager log --all --date-order --date=format:"%Y-%m-%d" --graph --format=" <%h> %ad [%an] %C(green)%d%Creset %s"'
abbr -a gst 'git status'
abbr -a gaa 'git add .'
abbr -a ga 'git add'
abbr -a gf 'git fetch'
abbr -a gb 'git branch'
abbr -a gdn 'git diff --name-only'
abbr -a gdan 'git --no-pager diff --name-only'

# Rust / Cargo
abbr -a cf 'cargo fmt'
abbr -a ch 'cargo check'
abbr -a cr 'cargo run'
abbr -a cb 'cargo build'
abbr -a cbrm 'cargo build --release && cargo build --release --target x86_64-unknown-linux-gnu && cargo build --release --target x86_64-pc-windows-gnu'

# tmux
abbr -a tl 'tmux ls'
abbr -a tr 'tmux kill-session -t'

# その他
abbr -a r 'rlwrap'
abbr -a rl 'rlwrap sbcl'
abbr -a cppr 'clang++ main.cpp -o out && ./out'
abbr -a f-l 'rg "function" ~/.config/fish/config.fish' # パスを変更
abbr -a help-vm 'glow $HOME/dotfiles/help_vmrun.md'
abbr -a rtss 'rts -cli | jq -r ".list[] | \"title: \\(.title)\\nlink: \\(.link)\\n\""'

if test (uname) = "Darwin"
    abbr -a copy 'pbcopy'
    abbr -a update 'brew update && brew upgrade && rustup update'
else
    abbr -a copy 'wl-copy'
end

# Starship (最後に実行)
# if type -q starship
#     starship init fish | source
# end
