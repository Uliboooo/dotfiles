{ config, pkgs, inputs, ... }:

{
  # ユーザー情報と管理対象ディレクトリ
  home.username = "coyuki";
  home.homeDirectory = "/home/coyuki";

  # Home Manager のバージョン互換性（変更しないこと）
  home.stateVersion = "24.11"; 

  # --- パッケージのインストール ---
  home.packages = with pkgs; [
    # --- ブラウザ ---
    firefox
    google-chrome
    inputs.zen-browser.packages."${pkgs.system}".default

    # --- ターミナル ---
    alacritty
    kitty
    foot
    inputs.ghostty.packages."${pkgs.system}".default
    starship
    tmux
    zellij

    # --- エディタ ---
    neovim
    vscode
    helix
    zed-editor

    # --- クリエイティブ ---
    blender
    gimp
    inkscape
    krita
    obs-studio

    # --- マルチメディア ---
    vlc
    
    # --- デスクトップ環境・ツール ---
    # Arch Linux上ではシステム側でHyprlandを入れている場合が多いですが、
    # ここで入れておくとNix版のバイナリがパスに追加されます。
    hyprland
    waybar
    wofi
    fuzzel
    dunst
    swaync
    swaybg
    hyprpaper
    hyprlock
    hypridle
    grim
    slurp
    wl-clipboard
    cliphist
    pavucontrol
    brightnessctl
    nwg-drawer
    avizo

    # --- ファイルマネージャー ---
    nautilus
    dolphin
    yazi
    
    # --- CLI ツール ---
    git
    lazygit
    gh
    ripgrep
    fd
    bat
    eza
    fzf
    jq
    htop
    btop
    bottom
    fastfetch
    tldr
    wget
    unzip
    zip
    p7zip
    rsync
    duf
    ncdu
    
    # --- 開発ツール / 言語ランタイム ---
    # プロジェクトごとのバージョン管理には `nix develop` (shell.nix) の使用を推奨しますが
    # 汎用的に使えるようにシステムワイドに入れます。
    gcc
    gnumake
    cmake
    go
    rustc
    cargo
    nodejs_22
    python3
    zig
    jdk
  ];

  # Home Manager 自体を管理
  programs.home-manager.enable = true;
  
  # Git の基本設定 (Arch側の設定を上書きしたい場合のみ有効化してください)
  # programs.git = {
  #   enable = true;
  #   userName = "Your Name";
  #   userEmail = "you@example.com";
  # };

  # シェル統合 (環境変数の自動設定など)
  programs.zsh.enable = true;
  programs.starship.enable = true;
}
