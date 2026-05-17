{ pkgs, ... }:
{
  # 全ホスト共通の最小セット
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
    neovim
    tmux
    ripgrep
    fd
    fzf
    eza
    bat
    gh
    nodejs
    zip
    unzip
    python3
  ];

  # sudo 可能にする基本設定
  security.sudo.wheelNeedsPassword = true;
}
