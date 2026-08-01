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

  # DNS は systemd-resolved に一本化する。dns = "none" のままだと tailscaled が
  # resolv.conf を「直接書き換えて良い」と判断し (direct manager)、Tailscale 起動中は
  # /etc/resolv.conf が nameserver 100.100.100.100 だけに置き換わって下の 1.1.1.1 が
  # 完全に無視される。resolved を挟むと tailscaled は D-Bus (SetLinkDNS/SetLinkDomains)
  # 経由で tailscale0 リンクにだけ 100.100.100.100 と ~<tailnet>.ts.net を登録するので、
  # MagicDNS は効いたままグローバルな解決先は 1.1.1.1 に残る。
  #
  # 前提: 管理コンソールの DNS → "Override local DNS" は無効のままにすること。有効だと
  # tailscaled が tailscale0 に ~. (デフォルトルート) を張り、結局全クエリが MagicDNS に
  # 吸われる。
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  # resolved の DNS= になる (services.resolved.settings.Resolve.DNS の既定値)。
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  # DHCP が配ってくる DNS を NetworkManager がリンク単位で resolved に push すると、
  # そちらが上の DNS= より優先されて 1.1.1.1 に来なくなる。全接続で既定 off にして
  # dns = "none" 時代の「常に 1.1.1.1」という挙動を維持する。
  # 副作用としてルータのローカル名前解決 (foo.local 等) は引けないが、これは従来と同じ。
  networking.networkmanager.connectionConfig = {
    "ipv4.ignore-auto-dns" = true;
    "ipv6.ignore-auto-dns" = true;
  };
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

  # lid を閉じたときの挙動。logind は 3 つを状況で使い分ける:
  #   HandleLidSwitchDocked        … ドック中(外部モニタ接続中)。最優先
  #   HandleLidSwitchExternalPower … AC 接続中かつ非ドック
  #   HandleLidSwitch              … それ以外(= バッテリー かつ 非ドック)
  #
  # 3 つとも suspend。外部モニタ接続中は logind が「ドック」と判定し、
  # HandleLidSwitchDocked の既定値 ignore だと lid を閉じても何も起きない
  # （＝ロックもされない）ので、明示的に指定する必要がある。suspend すれば
  # hypridle の before_sleep_cmd = loginctl lock-session が走り復帰時にロック
  # される。
  #
  # HandleLidSwitch = "hibernate" は試したが戻した(2026-07-25)。この機は
  # /sys/power/mem_sleep が [s2idle] のみ(Modern Standby, S3 無し)なので S4 に
  # 落とせれば持ち運び中の電力はほぼゼロにできる。しかし蓋起因の hibernate は
  # amdgpu と競合して危険:
  #   16:03:18 Lid closed / Hibernating...
  #   16:03:19 Lid opened            ← 凍結処理中(6 秒超)に開け直した
  #   16:03:26 soft lockup, Tainted: [D]=DIE
  #   16:03:54 amdgpu_dm_atomic_commit_tail → amdgpu_bo_unpin → ttm_bo_unpin
  #            _raw_spin_lock で停止 → ハング → 強制電源断
  # イメージは書かれないので次回は cold boot(PM: Image not found (code -22))に
  # なりセッションが飛ぶ。同日 16:00 の試行も Lid opened と同時刻で中断した。
  # 一方 hypridle の 30 分アイドル hibernate は蓋イベントを伴わないため成功実績
  # がある(7/24 23:46 に 7391040 kbytes 書き込み → 翌 00:05 に resume 成功)。
  # よって長時間放置の省電力は hypridle 側に任せ、蓋は suspend に留める。
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "suspend";
  };

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

  # ===== ハイバネート(S4)用 swap =====
  # このマシンは Modern Standby (S0ix) 専用で S3 が無いため、離席時の電池を
  # 抑えるには s2idle からさらに S4(hibernate) へ落とす必要がある。既存の
  # swap パーティション(luks-82faf233)は 8.8GiB しかなく RAM 30GiB を退避
  # できないので、root(ext4) 上に RAM 超の swapfile を置く。
  #
  swapDevices = [
    {
      device = "/swapfile";
      size = 34 * 1024; # MiB = 34 GiB (> RAM 30GiB)
    }
  ];

  # ハイバネートからの復帰設定。/swapfile は root(=luks-5c4ff8a1 の ext4)上に
  # あるので resumeDevice はその mapper。resume_offset は swapfile の先頭物理
  # ブロック番号（`filefrag -v /swapfile` の 0: の physical_offset 開始値、
  # 単位 4KiB = PAGE_SIZE）。swapfile を再作成したら必ず取り直すこと。
  boot.resumeDevice = "/dev/mapper/luks-5c4ff8a1-c35d-4244-8a36-f81bc112f164";
  boot.kernelParams = [ "resume_offset=78503936" ];

  # hibernate は hypridle が「アイドル 30 分 → バッテリー駆動時のみ
  # systemctl hibernate」で直接発行する（.config/hypr/hypridle.conf）。AC(ドック)
  # 時はしない: ドック中の S4 は USB-C/PCIe PME wake で巻き戻り再起動になる上、
  # AC 時はそもそも落としたくないため。この機は wake 可能な RTC が s2idle から
  # 起こせず suspend-then-hibernate が成立しないので、s2idle を挟まず直接 S4 に
  # 落とす。したがって HibernateDelaySec は不要。

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
