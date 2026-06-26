{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
    neovim
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
