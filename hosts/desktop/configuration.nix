{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/desktop.nix
    # ../../modules/thinkpad.nix
  ];

  networking.hostName = "desktop";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "ja_JP.UTF-8";

  # flakes コマンドを常用できるようにする
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # 利用中アプリ都合で unfree を許可
  nixpkgs.config.allowUnfree = true;

  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  # ここはマシン導入時に決めた値から変更しない
  system.stateVersion = "24.11";
}
