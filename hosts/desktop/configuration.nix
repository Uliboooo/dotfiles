{ pkgs, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/desktop.nix
    inputs.nix-hazkey.nixosModules.hazkey
    # ../../modules/thinkpad.nix
  ];

  networking.hostName = "desktop";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
  };
  services.hazkey.enable = true;

  # UEFI 環境向けの基本ブートローダー設定
  # Legacy BIOS の場合は grub 設定へ差し替えてください
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # flakes コマンドを常用できるようにする
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # bun/npm で入れた動的リンク実行ファイル (copilot など) を動かす
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
  stdenv.cc.cc
  zlib
  openssl
];

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
