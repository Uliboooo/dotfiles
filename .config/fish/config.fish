if status is-interactive
    abbr -a ff fastfetch

    # --- OS別設定 ---
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

    else
        if test -f /etc/os-release
            set DIST (string replace -r '^NAME=["\']?(.*)["\']?$' '$1' (grep '^NAME=' /etc/os-release))
        end

        fish_add_path /opt/rocm/bin
        set -gx LD_LIBRARY_PATH $LD_LIBRARY_PATH /opt/rocm/lib
        set -gx ROCM_PATH /opt/rocm

        set -gx HSA_OVERRIDE_GFX_VERSION 10.3.0
        set -gx OLLAMA_DEBUG 1
        set -gx OLLAMA_HOST 0.0.0.0:11434

        if set -q XDG_RUNTIME_DIR
            set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/keyring/ssh
        end

        if test -f "/home/coyuki/.local/share/swiftly/env.fish"
            source "/home/coyuki/.local/share/swiftly/env.fish"
        end
    end

    # cargo
    fish_add_path $HOME/.cargo/bin
    # adb
    fish_add_path $HOME/Library/Android/sdk/platform-tools
    # lm studio
    fish_add_path $HOME/.lmstudio/bin
    # Tex
    fish_add_path /Library/TeX/texbin
    # npm
    fish_add_path $HOME/.npm-global/bin
    # clangd (llvm@20)
    fish_add_path /opt/homebrew/opt/llvm@20/bin
    # My tools
    fish_add_path $HOME/my_tools/bin
    # My apps
    fish_add_path $HOME/my_apps/bin
    # Moonbit
    fish_add_path $HOME/.moon/bin

    # --- Starship の初期化 ---
    type -q starship; and starship init fish | source

    # --- .env ファイルの読み込み ---
    if test -f "$HOME/.env"
        for line in (grep -v '^#' "$HOME/.env")
            set -l item (string split -m 1 '=' $line)
            set -gx $item[1] $item[2]
        end
    end

    # --- 環境変数 ---
    set -gx GTK_IM_MODULE fcitx
    set -gx QT_IM_MODULE fcitx
    set -gx XMODIFIERS @im=fcitx
    set -gx HYPRSHOT_DIR "$HOME/Pictures/ScreenShots"

end
