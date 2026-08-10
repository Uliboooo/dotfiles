# niri

niri の外部ツールと、その設定上の前提を記録する。

## 2026-08-11

### niri-scratchpad の stash workspace

対象: `flake.nix`, `flake.lock`, `home/common_user.nix`, `.config/niri/config.kdl`

`niri-scratchpad-rs` は flake の `packages.<system>.default` を Home Manager の
`home.packages` に入れる。静的・動的いずれの scratchpad も、退避先として niri に
`workspace "stash" { }` が定義されていることを要求するため、設定にも追加した。

- Comamoca/dotfiles と同じ static scratchpad 方式にした。`Super+BracketLeft` は
  `ghostty --class=com.mitchellh.ghostty.scratch --background-opacity=0.8 --window-width=120 --window-height=60`
  を初回だけ起動し、以後は同 app-id のウィンドウを表示・退避する。通常の Ghostty を
  一緒に退避させないよう専用 app-id と、その浮動表示 rule を使う。scratchpad だけ共通設定の
  `background-opacity = 0.5` を 0.8 で上書きし、初期サイズを 120×60 terminal cells にする。
  Ghostty GTK の `class` は Wayland app-id でもあり、GTK の reverse-DNS 形式に従う必要が
  あるため、`ghostty-scratch` のようなドット無しの値は使わない。static targeting に daemon は不要。
- 上流 README の Nix 例は `inputs.niri-scratchpad.packages.${pkgs.system}.default`、
  stash workspace の必須要件は同 README (2026-08-11 確認) による。
- `nix eval .#nixosConfigurations.desktop.config.home-manager.users.seli.home.activationPackage.drvPath`
  は成功した。`nix build --no-link .#nixosConfigurations.desktop.config.system.build.toplevel`
  も評価を通過し、`niri-scratchpad-2.0.0.drv` を含むビルド計画を生成した。
