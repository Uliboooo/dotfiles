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
    eza
    bat
    gh
  ];

  # sudo 可能にする基本設定
  security.sudo.wheelNeedsPassword = true;
}
