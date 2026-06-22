# home/alice.nix
{ pkgs, lib, ... }:
{
  imports = [ ./common_user.nix ];
  home.username = "alice";

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        UseKeychain = "yes";
        AddKeysToAgent = "yes";
      };
    };
  };
}
