{ config, pkgs, ... }:
let
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
  npmGlobalDir = "${config.home.homeDirectory}/.npm-global";
  bunInstallDir = "${config.home.homeDirectory}/.cache/.bun";
  bunBinDir = "${bunInstallDir}/bin";

  mkConfigLink = name:
    # the actual files are fixed dotfiles/.config/<name>
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/${name}";
in
{
  home.username = "alice";
  home.homeDirectory = "/home/alice";
  home.stateVersion = "24.11";
  nixpkgs.config.allowUnfree = true;

  home.sessionVariables = {
    CC = "clang";
    CXX = "clang++";
    LD = "lld";
  };

  # ===== personal ====
  home.packages = with pkgs; [
    git
    neovim
    kitty
    yazi
    fzf
    fastfetch
    bun
    sheldon
    zsh-abbr
    lazygit
    gh
    zip
    unzip
    ghq
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
    google-chrome
    btop
    bluetui
    pulsemixer
    brightnessctl
    difftastic
    playerctl
    tokei
    wget
    go
    gopls
    zig
    zls
    ghostty
    jq
    hollywood
    tree-sitter
    clang
    llvm
    lld
    restic
    libreoffice
  ];

  # moving global npm installs to the user direcotry to avoid permission errors
  home.sessionVariables = {
    NPM_CONFIG_PREFIX = npmGlobalDir;
    BUN_INSTALL = bunInstallDir;
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
    "kitty" = {
      source = mkConfigLink "kitty";
      recursive = false;
    };
    "hypr" = {
      source = mkConfigLink "hypr";
      recursive = false;
    };
    "waybar" = {
      source = mkConfigLink "waybar";
      recursive = false;
    };

    # 既存運用に合わせて必要なものを順次追加
    "git" = {
      source = mkConfigLink "git";
      recursive = false;
    };
    "yazi" = {
      source = mkConfigLink "yazi";
      recursive = false;
    };
    "fish" = {
      source = mkConfigLink "fish";
      recursive = false;
    };
    "rofi" = {
      source = mkConfigLink "rofi";
      recursive = false;
    };
    "swaync" = {
      source = mkConfigLink "swaync";
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
    "systemd/user/cycle_wallpaper.service".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/systemd/user/cycle_wallpaper.service";
    "systemd/user/cycle_wallpaper.timer".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/systemd/user/cycle_wallpaper.timer";
    "systemd/user/ssh-agent.service".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/systemd/user/ssh-agent.service";
  };

  home.file.".zshrc".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.zshrc";
}
