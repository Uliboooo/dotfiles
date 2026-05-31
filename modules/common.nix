{ pkgs, ... }:
{
  # 全ホスト共通の最小セット
  # minimal set common to all hosts
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

  security.sudo.wheelNeedsPassword = true;
}
