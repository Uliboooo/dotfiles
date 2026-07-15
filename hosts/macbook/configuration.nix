{ pkgs, ... }:
{
  # nixpkgs.hostPlatform は flake.nix の darwinSystem から渡される。
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = 7;
  # user 単位のオプション (defaults 等) の適用先。これが無いと assertion で落ちる。
  system.primaryUser = "seli";

  users.users.seli = {
    name = "seli";
    home = "/Users/seli";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # /etc/zshrc から nix プロファイルを PATH に載せる。
  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];

  environment.systemPackages = with pkgs; [
    git
    curl
    vim
  ];
}
