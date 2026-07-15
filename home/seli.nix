{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  isDarwin = pkgs.stdenv.isDarwin;

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

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      AddKeysToAgent = "yes";
    }
    // lib.optionalAttrs isDarwin {
      # Keychain に登録した passphrase を再入力なしで使う。macOS 版 ssh 限定。
      UseKeychain = "yes";
    };
  };

  fonts.fontconfig.enable = true;

  # XDG user dirs は freedesktop の仕様で、macOS には ~/Desktop 等が既にある。
  xdg.userDirs = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    createDirectories = true;
    setSessionVariables = false;
  };

  home.packages = [
    tex
  ];
}
