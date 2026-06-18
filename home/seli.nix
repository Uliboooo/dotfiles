{
  config,
  pkgs,
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
  imports = [ ./common_user.nix ];

  home.username = pkgs.lib.mkDefault "seli";

  fonts.fontconfig.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  home.packages = [
    tex
  ];
}
