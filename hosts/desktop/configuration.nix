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
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "start";
  };

  hardware.enableAllFirmware = true;

  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    # GTK_IM_MODULE/QT_IM_MODULE を設定しない (XMODIFIERS は残るので XWayland は XIM で動く)。
    # GTK3 は GTK_IM_MODULE の値に関係なく zwp_text_input_v3 を張るため、これを設定すると
    # Firefox が DBus フロントエンドと wayland_v2 フロントエンドの両方に InputContext を
    # 持ってしまう。どちらがフォーカスを取るかがウィンドウごと・タイミングごとに変わり、
    # classicui が候補ウィンドウを描き直すたびにちらつく。経路を wayland_v2 の一本に揃える。
    fcitx5.waylandFrontend = true;
  };
  services.hazkey.enable = true;
  services.tailscale.enable = true;

  services.udisks2.enable = true;
  services.gvfs.enable = true;

  services.fprintd.enable = true;
  security.pam.services = {
    login.fprintAuth = lib.mkForce true;
    sudo.fprintAuth = true;
    # hyprlock scans the sensor itself over fprintd's DBus API. Leaving
    # pam_fprintd in the stack (fprintAuth defaults to services.fprintd.enable)
    # makes PAM claim the same device concurrently, which breaks both paths.
    hyprlock.fprintAuth = false;
  };

  # nixbuild.net remote builder. The nix-daemon runs as root, so the key must be
  # passphrase-less and reachable from root's ssh config (/etc/ssh/ssh_config).
  programs.ssh.extraConfig = ''
    Host eu.nixbuild.net
      PubkeyAcceptedKeyTypes ssh-ed25519
      ServerAliveInterval 60
      IdentityFile /home/seli/.ssh/nixbuild
  '';

  programs.ssh.knownHosts.nixbuild = {
    hostNames = [ "eu.nixbuild.net" ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
  };

  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "eu.nixbuild.net";
      system = "x86_64-linux";
      maxJobs = 100;
      supportedFeatures = [
        "benchmark"
        "big-parallel"
      ];
    }
  ];
  # Let nixbuild.net fetch dependencies from cache.nixos.org itself instead of
  # uploading them from this machine.
  nix.settings.builders-use-substitutes = true;

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
  # gcr-ssh-agent は鍵の解錠時に ssh-add を fork し、passphrase を askpass 経由で
  # キーリングから取る。セッション環境に SSH_ASKPASS_REQUIRE=never が紛れ込むと
  # ssh-add が askpass を拒否して署名が「agent refused operation」で落ちるため、
  # このサービスでは明示的に落とす（シェル rc からの流入に対する保険）。
  systemd.user.services.gcr-ssh-agent.serviceConfig.UnsetEnvironment = [
    "SSH_ASKPASS_REQUIRE"
    "SSH_ASKPASS"
  ];

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
    shell = pkgs.fish;
  };

  programs.zsh.enable = true;
  programs.fish.enable = true;

  # Manage /etc/crypttab via Nix to override manual/broken entries
  environment.etc."crypttab".text = lib.mkForce "";

  system.stateVersion = "24.11";

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
}
