{ config, pkgs, ... }:
let
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
  npmGlobalDir = "${config.home.homeDirectory}/.npm-global";
  bunBinDir = "${config.home.homeDirectory}/.bun/bin";

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
    bun
  ];

  # npm の global install をユーザー領域へ逃がして権限エラーを回避
  home.sessionVariables.NPM_CONFIG_PREFIX = npmGlobalDir;
  home.sessionPath = [
    "${npmGlobalDir}/bin"
    bunBinDir
  ];

  programs.git = {
    enable = true;
    settings.user = {
      name = "Alice";
      email = "alice@example.com";
    };
  };

  programs.kitty.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    # 26.05 以降のデフォルトに合わせて警告を抑制
    withRuby = false;
    withPython3 = false;
  };
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
  };
  programs.zsh = {
    enable = true;
    # $HOME 直下運用を明示（絶対パスは使わない）
    dotDir = ".";
  };

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
}
