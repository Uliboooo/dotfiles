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
  # tirith = inputs.tirith.packages.${pkgs.system}.default;
  zathura-gui = inputs.zathura-gui.packages.${system}.default;
  # shojiwm = inputs.shojiwm.packages.${pkgs.system}.default;
  hyprpanopticon = inputs.hyprpanopticon.packages.${system}.default;

  packages = with pkgs; [
    # ===== CLI / エディタ =====
    git
    vim
    neovim
    emacs-pgtk
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
    tinymist
    dust
    glow
    # inputs.antigravity.packages.${pkgs.system}.default
    antigravity-cli
    # antigravity
    taplo
    imagemagick
    chafa
    codex
    # tirith
    claude-code
    opencode

    # ===== GUI アプリ =====
    obsidian
    spotify
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
    google-chrome
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
    discord
    gnome-text-editor
    gnome-tweaks
    ashell
    # noctalia-shell
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
    hyprpanopticon
    # shojiwm
    chromium
    geeqie
    zed-editor
    digikam
    prismlauncher

    # ===== ツールチェーン =====
    clang
    llvm
    lld
    tailscale
  ];

  mkConfigLink = name: config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/${name}";
in
{
  config = {
    home.username = pkgs.lib.mkDefault "seli";
    home.homeDirectory = pkgs.lib.mkDefault "/home/${config.home.username}";
    home.stateVersion = "24.11";

    programs.home-manager.enable = true;

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
    programs.crush.enable = true;

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

    targets.genericLinux.enable = true;

    # ===== packages =====
    home.packages = packages;

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
      "swaync" = {
        source = mkConfigLink "swaync";
        recursive = false;
      };
      "nixpkgs" = {
        source = mkConfigLink "nixpkgs";
        recursive = false;
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
  };
}
