{
  config,
  pkgs,
  inputs,
  ...
}:
let
  tex = pkgs.texliveSmall.withPackages (ps: with ps; [
    collection-langjapanese   # luatexja 等の日本語サポート
    collection-luatex          # LuaLaTeX エンジン
    collection-latexextra      # 汎用パッケージ群
    haranoaji                  # 原ノ味フォント（明朝・TeX Live 内蔵）
    haranoaji-extra            # 原ノ味フォント（ゴシック）
    fontspec
    hyperref
    latexmk                    # 自動コンパイルツール
  ]);
in
{
  imports = [ ./common_user.nix ];

  home.username = pkgs.lib.mkDefault "lilan";

  fonts.fontconfig.enable = true;

  home.packages = [
    tex
  ];
}
