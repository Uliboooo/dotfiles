{ config, pkgs, ... }:
let
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
  npmGlobalDir = "${config.home.homeDirectory}/.npm-global";
  bunBinDir = "${config.home.homeDirectory}/.bun/bin";

  # 将来的に ~/dotfiles/<app> へ移行しても動くように
  # 現在の実体配置に合わせて
  # 1) ~/dotfiles/.config/<app>
  # 2) ~/dotfiles/<app>
  # の順で参照する。
  resolveAppDir = name:
    let
      topLevel = "${dotfilesDir}/${name}";
      legacy = "${dotfilesDir}/.config/${name}";
    in
    if builtins.pathExists legacy then legacy else topLevel;

  mkConfigLink = name:
    config.lib.file.mkOutOfStoreSymlink (resolveAppDir name);
in
{
  home.username = "alice";
  home.homeDirectory = "/home/alice";
  home.stateVersion = "24.11";

  # ===== 個人レイヤー =====
  # 個人で使う CLI/TUI は Home Manager 側で管理
  home.packages = with pkgs; [
    git
    neovim
    kitty
    yazi
    fzf
    fastfetch
    bun
  ];

  # npm の global install をユーザー領域へ逃がして権限エラーを回避
  home.sessionVariables.NPM_CONFIG_PREFIX = npmGlobalDir;
  home.sessionPath = [
    "${npmGlobalDir}/bin"
    bunBinDir
  ];

  xdg.enable = true;
  xdg.configFile = {
    # 実体は dotfiles 側の「普通のファイル/ディレクトリ」を使う
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
  };

  # zsh は dotfiles 実体をそのまま使う
  home.file.".zshrc".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.zshrc";
}
