{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  tex = pkgs.texliveSmall.withPackages (
    ps: with ps; [
      collection-langjapanese
      collection-luatex
      collection-latexextra
      haranoaji
      haranoaji-extra
      fontspec
      hyperref
      latexmk
    ]
  );
in
{
  imports = [
    ./common_user.nix
  ];

  home.username = pkgs.lib.mkDefault "seli";

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      AddKeysToAgent = "yes";
    };
  };

  fonts.fontconfig.enable = true;

  # XDG user dirs は freedesktop の仕様。
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = false;
  };

  home.packages = [
    tex
  ];
}
