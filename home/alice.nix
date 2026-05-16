{ config, pkgs, ... }:
let
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";

  # 将来的に ~/dotfiles/<app> へ移行しても動くように
  # 1) ~/dotfiles/<app>
  # 2) ~/dotfiles/.config/<app>
  # の順で参照する。
  resolveAppDir = name:
    let
      topLevel = "${dotfilesDir}/${name}";
      legacy = "${dotfilesDir}/.config/${name}";
    in
    if builtins.pathExists topLevel then topLevel else legacy;

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
    yazi
    fzf
    fastfetch
  ];

  programs.git = {
    enable = true;
    userName = "Alice";
    userEmail = "alice@example.com";
  };

  programs.kitty.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  programs.yazi.enable = true;
  programs.zsh.enable = true;

  xdg.enable = true;
  xdg.configFile = {
    # 実体は dotfiles 側の「普通のファイル/ディレクトリ」を使う
    "nvim".source = mkConfigLink "nvim";
    "kitty".source = mkConfigLink "kitty";
    "hypr".source = mkConfigLink "hypr";
    "waybar".source = mkConfigLink "waybar";

    # 既存運用に合わせて必要なものを順次追加
    "git".source = mkConfigLink "git";
    "yazi".source = mkConfigLink "yazi";
    "fish".source = mkConfigLink "fish";
    "rofi".source = mkConfigLink "rofi";
    "swaync".source = mkConfigLink "swaync";
  };

  # ~/.zshrc も dotfiles 実体を参照
  home.file.".zshrc".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.zshrc";
}
