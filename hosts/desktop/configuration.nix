{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/desktop.nix
    inputs.nix-hazkey.nixosModules.hazkey
    # ../../modules/thinkpad.nix
  ];

  networking.hostName = "selitank";
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "none";
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  hardware.enableAllFirmware = true;

  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
  };
  services.hazkey.enable = true;
  services.tailscale.enable = true;
  services.flatpak.enable = true;

  services.udisks2.enable = true;
  services.gvfs.enable = true;

  services.fprintd.enable = true;
  security.pam.services = {
    login.fprintAuth = lib.mkForce true;
    sudo.fprintAuth = true;
  };

  # LUKS devices
  # boot.initrd.luks.devices = {
  # Swap partition
  # "luks-1dc20a4c-0384-4870-bb99-e5a65f1df495" = {
  #   device = "/dev/disk/by-uuid/1dc20a4c-0384-4870-bb99-e5a65f1df495";
  #   allowDiscards = true;
  # };
  # Backup disk
  # "bk_disk" = {
  #   device = "/dev/disk/by-uuid/86f101a3-83e7-42e6-9cba-06b2621f8db2";
  #   allowDiscards = true;
  # };
  # };

  fileSystems."/mnt/bk_disk" = {
    device = "/dev/mapper/bk_disk";
    fsType = "ext4";
    options = [
      "noauto"
      "nofail"
    ];
  };

  # bootloader configurations for UEFI
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    openssl
  ];

  programs.ssh.startAgent = false;
  services.gnome.gcr-ssh-agent.enable = true;

  programs.direnv.enable = true;

  nixpkgs.config.allowUnfree = true;

  users.users.seli = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "kvm"
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  # Manage /etc/crypttab via Nix to override manual/broken entries
  environment.etc."crypttab".text = lib.mkForce "";

  system.stateVersion = "24.11";

  nix.gc = {
    automatic = true;
    dates = "dayly";
    options = "--delete-older-than 7d";
  };
}
