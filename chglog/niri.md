# niri

niri の外部ツールと、その設定上の前提を記録する。

## 2026-08-14

### overview の backdrop に awww を配置する

対象: `.config/niri/config.kdl`

この環境の awww layer-shell surface の namespace は `awww-daemon`。`niri msg layers`
で実機確認した。`layout.background-color "transparent"` と namespace を限定した
`place-within-backdrop true` を組み合わせると、overview でも壁紙を backdrop に残し、
workspace と一緒に壁紙が縮小・移動するのを防げる。

## 2026-08-11

### niri-scratchpad の stash workspace

対象: `flake.nix`, `flake.lock`, `home/common_user.nix`, `.config/niri/config.kdl`

`niri-scratchpad-rs` は flake の `packages.<system>.default` を Home Manager の
`home.packages` に入れる。静的・動的いずれの scratchpad も、退避先として niri に
`workspace "stash" { }` が定義されていることを要求するため、設定にも追加した。

- static scratchpad は `Super+BracketLeft` などで専用 Emacs フレームを初回だけ起動し、
  以後は title が `Scratchpad Emacs` のフレームだけを表示・退避する。
  `emacs-scratch` は Home Manager で定義した emacsclient wrapper であり、
  通常 daemon には接続せず、独立した Emacs プロセスをこの title で起動する。通常の
  Emacs とは別プロセスなので、scratchpad のバッファは rofi 等から開く Emacs に混ざらない。
  title により scratchpad フレームだけが浮動表示になる。
- 上流 README の Nix 例は `inputs.niri-scratchpad.packages.${pkgs.system}.default`、
  stash workspace の必須要件は同 README (2026-08-11 確認) による。
- `nix eval .#nixosConfigurations.desktop.config.home-manager.users.seli.home.activationPackage.drvPath`
  は成功した。`nix build --no-link .#nixosConfigurations.desktop.config.system.build.toplevel`
  も評価を通過し、`niri-scratchpad-2.0.0.drv` を含むビルド計画を生成した。
