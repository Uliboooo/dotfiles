{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
  npmGlobalDir = "${config.home.homeDirectory}/.npm-global";
  bunInstallDir = "${config.home.homeDirectory}/.cache/.bun";
  bunBinDir = "${bunInstallDir}/bin";

  system = pkgs.stdenv.hostPlatform.system;

  wlmstr = inputs.wlmstr.packages.${system}.default;
  zathura-gui = inputs.zathura-gui.packages.${system}.default;
  niri-float-sticky = inputs.niri-float-sticky.packages.${system}.default;
  niri-scratchpad = inputs.niri-scratchpad.packages.${system}.default;
  firefox-nightly = inputs.firefox-nightly.packages.${system}.firefox-nightly-bin;
  zen-browser = inputs.zen-browser.packages.${system}.zen-browser;
  emacsClient = pkgs.writeShellScriptBin "emacs" ''
    exec ${lib.getExe' pkgs.emacs-pgtk "emacsclient"} --create-frame "$@"
  '';
  emacsScratch = pkgs.writeShellScriptBin "emacs-scratch" ''
    # A second PGTK instance crashes while the daemon is running.  Make the
    # scratchpad a titled, floating frame in the existing daemon instead.
    exec ${lib.getExe' pkgs.emacs-pgtk "emacsclient"} \
      --create-frame \
      --frame-parameters='((title . "Scratchpad Emacs"))' \
      "$@"
  '';
  orgGitSync = pkgs.writeShellApplication {
    name = "org-git-sync";
    runtimeInputs = with pkgs; [
      coreutils
      git
    ];
    text = ''
      org_dir="${config.home.homeDirectory}/org"

      if [[ ! -d "$org_dir/.git" ]]; then
        echo "org-git-sync: $org_dir is not a Git repository" >&2
        exit 1
      fi

      cd "$org_dir"
      git pull
      git add .

      if ! git diff --cached --quiet; then
        changed_files_list="$(git diff --cached --name-only | paste -sd, -)"
        git commit -m "org mode chagens: $changed_files_list"
      fi

      git push
    '';
  };

  # `nix.gc` is a system service and does not manage profiles in this user's
  # XDG state directory.  Expire their generations before the nightly system
  # GC so their auto roots can become collectable.
  nixProfilePrune = pkgs.writeShellApplication {
    name = "nix-profile-prune";
    runtimeInputs = [ pkgs.nix ];
    text = ''
      for profile in \
        "${config.home.homeDirectory}/.local/state/nix/profiles/profile" \
        "${config.home.homeDirectory}/.local/state/nix/profiles/home-manager"; do
        if [[ -L "$profile" ]]; then
          nix-env --profile "$profile" --delete-generations 7d
        fi
      done
    '';
  };
  packages = with pkgs; [
    # ===== CLI / エディタ =====
    git
    vim
    neovim
    helix
    yazi
    fzf
    fastfetch
    bun
    nodejs
    sheldon
    zsh
    zsh-abbr
    fish
    lazygit
    gh
    zip
    unzip
    ghq
    btop
    htop
    difftastic
    tokei
    wget
    kitty
    go
    gopls
    zig
    zls
    jq
    asciiquarium
    tmux-mem-cpu-load
    tree-sitter
    restic
    ffmpeg
    biome
    stylua
    shfmt
    statix
    deadnix
    nil
    nixfmt
    typescript
    mediainfo
    rust-analyzer
    rustfmt
    cargo
    fd
    ripgrep
    eza
    bat
    direnv
    nix-direnv
    typst
    typstyle
    tinymist
    dust
    glow
    antigravity-cli
    taplo
    imagemagick
    chafa
    codex
    claude-code
    opencode

    # ===== GUI アプリ =====
    spotify
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
    google-chrome
    zen-browser
    zathura
    sioyek # Qt だが qtbase の platformtheme 経由で gtk+3 を引く
    pinta
    inkscape
    nautilus
    loupe
    clapper
    showtime
    libreoffice
    firefox
    firefox-nightly
    discord
    vesktop
    gnome-text-editor
    gnome-tweaks
    ashell
    noctalia
    kdePackages.kdenlive
    libnotify # freedesktop の D-Bus 通知
    mpv
    wl-clipboard
    wlrctl # binds.lua の ALT+J/K (pointer scroll) が依存する。
    ghostty
    hollywood
    bluetui
    pulsemixer
    brightnessctl
    playerctl
    ffmpegthumbnailer
    vlc
    wiremix
    mpvpaper
    wlmstr
    zathura-gui
    # shojiwm
    chromium
    geeqie
    digikam
    prismlauncher
    niri-float-sticky
    niri-scratchpad
    wooz

    # ===== ツールチェーン =====
    clang
    clang-tools
    llvm
    lld
    tailscale

    gnupg
    pinentry-qt
  ];

  mkConfigLink = name: config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/${name}";
in
{
  config = {
    home.username = pkgs.lib.mkDefault "seli";
    home.homeDirectory = pkgs.lib.mkDefault "/home/${config.home.username}";
    home.stateVersion = "24.11";

    programs.home-manager.enable = true;

    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      enableZshIntegration = true;
      # Git など端末から呼ばれる gpg にも、デスクトップ上で認証ダイアログを出す。
      pinentry.package = pkgs.pinentry-qt;
      # デスクトップのログインセッション中は Git 署名などで再入力しない。
      # ログアウトまたは agent の再起動時にはキャッシュも失われる。
      defaultCacheTtl = 43200;
      maxCacheTtl = 43200;
    };

    programs.zsh = {
      enable = true;
      dotDir = "${config.home.homeDirectory}/.config/zsh";
      # compinit は dotfiles/.zshrc 側が呼ぶ。non-nix なマシンでも同じ .zshrc を
      # 使うため、そちらを正とする。true にすると compinit が二重に走る。
      enableCompletion = false;
      initContent = ''
        if [ -f "${dotfilesDir}/.zshrc" ]; then
          source "${dotfilesDir}/.zshrc"
        fi
      '';
    };

    programs.obs-studio = {
      enable = true;

      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
      ];
    };
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # PGTK applications (including GUI Emacs) read the GTK cursor setting.
    # Keep it aligned with the compositor's XCURSOR_* configuration.
    gtk = {
      enable = true;
      cursorTheme = {
        name = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
        size = 20;
      };
    };

    programs.tmux = {
      enable = true;
      package = pkgs.tmux;
      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        battery
        cpu
        resurrect
        continuum
        catppuccin
      ];
      extraConfig = builtins.readFile ../.tmux.conf;
    };

    # 通常用 Emacs は graphical-session.target で daemon として一度だけ起動する。
    # `emacs` は優先度の高い client wrapper に置き換えるため、端末からも
    # rofi からも既存の daemon に新しいフレームを要求する。
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;
    };
    services.emacs = {
      enable = true;
      startWithUserSession = "graphical";
      defaultEditor = true;
      client.enable = false;
      # systemd user service では XDG_CONFIG_HOME が引き継がれない環境がある。
      # init file を明示することで daemon でも常に dotfiles の設定を読み込む。
      extraOptions = [
        "--no-init-file"
        "--load"
        "${dotfilesDir}/.config/emacs/init.el"
      ];
    };

    targets.genericLinux.enable = true;

    # ===== packages =====
    home.packages = packages ++ [
      (lib.hiPrio emacsClient)
      emacsScratch
    ];

    home.sessionVariables = {
      NPM_CONFIG_PREFIX = npmGlobalDir;
      BUN_INSTALL = bunInstallDir;
      CC = "clang";
      CXX = "clang++";
      LD = "lld";
    };
    home.sessionPath = [
      "${npmGlobalDir}/bin"
      bunBinDir
    ];

    xdg.enable = true;
    xdg.configFile = {
      "nvim" = {
        source = mkConfigLink "nvim";
        recursive = false;
      };
      "emacs" = {
        source = mkConfigLink "emacs";
        recursive = false;
      };
      "fastfetch" = {
        source = mkConfigLink "fastfetch";
        recursive = false;
      };
      "helix" = {
        source = mkConfigLink "helix";
        recursive = false;
      };
      "kitty" = {
        source = mkConfigLink "kitty";
        recursive = false;
      };
      "ghostty" = {
        source = mkConfigLink "ghostty";
        recursive = false;
      };
      "git" = {
        source = mkConfigLink "git";
        recursive = false;
      };
      "yazi" = {
        source = mkConfigLink "yazi";
        recursive = false;
      };
      "vim" = {
        source = mkConfigLink "vim";
        recursive = false;
      };
      "nix" = {
        source = mkConfigLink "nix";
        recursive = false;
      };
      "rofi" = {
        source = mkConfigLink "rofi";
        recursive = false;
      };
      "sheldon" = {
        source = mkConfigLink "sheldon";
        recursive = false;
      };
      "zsh-abbr" = {
        source = mkConfigLink "zsh-abbr";
        recursive = false;
      };
      # Because fisher writes to fish_plugins and functions/, we use a symlink outside the store
      # to directly reference the dotfiles side (with programs.fish, home-manager owns config.fish and conflicts).
      "fish" = {
        source = mkConfigLink "fish";
        recursive = false;
      };
      "btop" = {
        source = mkConfigLink "btop";
        recursive = false;
      };
      "ziggity" = {
        source = mkConfigLink "ziggity";
        recursive = false;
      };
      "opencode" = {
        source = mkConfigLink "opencode";
        recursive = false;
      };
      # Wayland/Hyprland 系の Linux-only configs
      "hypr" = {
        source = mkConfigLink "hypr";
        recursive = false;
      };
      "niri" = {
        source = mkConfigLink "niri";
        recursive = false;
      };
      "waybar" = {
        source = mkConfigLink "waybar";
        recursive = false;
      };
      "noctalia" = {
        source = mkConfigLink "noctalia";
        recursive = false;
      };
      "nixpkgs" = {
        source = mkConfigLink "nixpkgs";
        recursive = false;
      };
      "herdr" = {
        source = mkConfigLink "herdr";
        recursive = false;
      };
      "wlmstr" = {
        source = mkConfigLink "wlmstr";
        recursive = false;
      };
    };

    # パッケージ同梱の emacs.desktop を上書きして、rofi の "Emacs" からも
    # daemon へ接続する。Home Manager がユーザー側の desktop entry を高優先度にする。
    xdg.desktopEntries.emacs = {
      name = "Emacs";
      genericName = "Text Editor";
      comment = "Edit text with the Emacs daemon";
      exec = "${lib.getExe' pkgs.emacs-pgtk "emacsclient"} --create-frame %F";
      icon = "emacs";
      terminal = false;
      categories = [
        "Development"
        "TextEditor"
      ];
      mimeType = [
        "text/plain"
        "text/x-c"
        "text/x-c++"
        "text/x-java"
        "text/x-makefile"
      ];
      settings.StartupWMClass = "Emacsd";
    };

    # Picture-in-Picture ウィンドウを全 workspace で sticky にする。
    # 以前は niri の spawn-at-startup で起動していたが、niri の IPC ソケット
    # 切断時に CPU コアを食い尽くす既知バグがある
    # (https://github.com/probeldev/niri-float-sticky/issues/12)。niri と
    # 同じライフサイクルで綺麗に起動/終了させるため systemd user サービス化する。
    # NIRI_SOCKET / WAYLAND_DISPLAY は niri が子にしか渡さないため、
    # config.kdl の import-environment で manager 環境に注入している。
    systemd.user.services.niri-float-sticky = {
      Unit = {
        Description = "Make picture-in-picture windows stick across niri workspaces";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = lib.escapeShellArgs [
          (lib.getExe niri-float-sticky)
          "-title"
          "Picture in picture|Picture-in-Picture"
        ];
        Restart = "on-failure";
        RestartSec = 2;
        StandardOutput = "journal";
        StandardError = "journal";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };

    # ステータスバー Noctalia を Waybar の代替として systemd で管理する。
    # 以前は compositor の init.lua から直接起動していたが、クラッシュ時の
    # 自動再起動や journal へのログ出力を systemd に任せるためサービス化する。
    systemd.user.services.noctalia = {
      Unit = {
        Description = "Noctalia status bar";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        Conflicts = [ "waybar.service" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${lib.getExe pkgs.noctalia}";
        Restart = "on-failure";
        RestartSec = 2;
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    systemd.user.services.cycle_wallpaper = {
      Unit.Description = "wallpaper cycle by awww";

      Service = {
        Type = "oneshot";
        ExecStart = lib.escapeShellArgs [
          (lib.getExe wlmstr)
          "next"
          "seq"
        ];
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    systemd.user.timers.cycle_wallpaper = {
      Unit.Description = "Change wallpaper every 15 minutes";

      Timer = {
        OnBootSec = "1min";
        OnCalendar = "*-*-* *:00,15,30,45:00";
        Persistent = false;
      };

      Install.WantedBy = [ "timers.target" ];
    };

    systemd.user.services.cliphist-clean = {
      Unit.Description = "Clean cliphist";

      Service = {
        Type = "oneshot";
        ExecStart = "${lib.getExe pkgs.cliphist} wipe";
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    systemd.user.timers.cliphist-clean = {
      Unit.Description = "Clean cliphist every week";

      Timer = {
        OnCalendar = "weekly";
        Persistent = false;
      };

      Install.WantedBy = [ "timers.target" ];
    };

    systemd.user.services.nix-profile-prune = {
      Unit.Description = "Expire old Nix and Home Manager profile generations";

      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe nixProfilePrune;
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    systemd.user.timers.nix-profile-prune = {
      Unit.Description = "Expire user profile generations before nightly Nix GC";

      Timer = {
        OnCalendar = "*-*-* 23:40:00";
        Persistent = true;
        Unit = "nix-profile-prune.service";
      };

      Install.WantedBy = [ "timers.target" ];
    };

    systemd.user.services.org-git-sync = {
      Unit.Description = "Pull and commit changes in the org-mode repository";

      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe orgGitSync;
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    systemd.user.timers.org-git-sync = {
      Unit.Description = "Synchronize the org-mode repository every 5 minutes";

      Timer = {
        OnBootSec = "1min";
        OnUnitActiveSec = "5min";
        Unit = "org-git-sync.service";
        Persistent = false;
      };

      Install.WantedBy = [ "timers.target" ];
    };
  };
}
