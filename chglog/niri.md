# niri

niri の外部ツールと、その設定上の前提を記録する。

## 2026-08-29

### `still` と Wooz は重ねられない

触ったファイル: `home/common_user.nix`, `.config/niri/config.kdl`

`still -c 'wooz …'` は使えない。実機の `niri msg layers` で、`still` が overlay layer を
占有する一方、Wooz はそこに出ないことを確認した。overlay layer は通常ウィンドウより前面なので、
Wooz を完全に隠してしまう。`still` を止めても子の Wooz が残り得るため、これを keybind に組み
込むと終了処理も不完全になる。

そのため `still` は package から外し、`Super+Alt+Z` を Wooz 単体起動へ戻した。Niri で静止画を
背後に置いたまま Wooz だけを前面に出すことは、両者の layer/ウィンドウ種別が異なるため、設定だけでは
できない。

## 2026-08-18

### Kitty だけ背景 blur を許可

触ったファイル: `.config/niri/config.kdl`

Paper Design の非 blur 方針の例外として、`app-id=kitty` の window rule にだけ
`background-effect { blur true; }` を設定した。niri の global `blur` block はこの
window rule を機能させるために有効化しているが、ほかの window rule は blur を要求しない。

## 2026-08-17

### コンポジタ装飾を Paper Design に復帰

触ったファイル: `.config/niri/config.kdl`

active border は Paper Design の rose (`#d38ca0`) の単色、inactive は不透明な薄い罫線色
(`#989286`)、urgent は warning (`#a84435`) に戻した。角丸を 0 にし、グローバル blur と
terminal / Rofi の background blur を削除した。PiP も非透過に統一して、紙面に半透明の
レイヤーが残らないようにしている。

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
