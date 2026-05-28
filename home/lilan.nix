{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ ./common_user.nix ];
  home.username = "lilan";
  dotfiles.enableGui = false;
}
