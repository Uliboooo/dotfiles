# Kitty / Neovim のテーマ

Kitty / Ghostty は `TERM_BACKGROUND` を子プロセスへ渡し、Neovim は明示された値を
優先して起動時の Rosé Pine variant を選ぶ。値が無い場合は Neovim 0.12 組み込みの
OSC 11 背景検出を使う。端末の実際の背景と明示値は必ず揃える。

## 2026-09-04

### SSH では Neovim 組み込みの OSC 11 背景検出にもフォールバックする

- `.config/nvim/lua/plugins/visual.lua`
- `.config/ghostty/config`

Neovim 0.12 はユーザー設定を読む前に OSC 11 で端末の背景色を問い合わせ、輝度から
`background` を自動設定する。この問い合わせと応答は SSH 越しでも端末へ届く。
ところが従来設定は `TERM_BACKGROUND` が無い場合に `background=dark` を明示して、
組み込みの検出結果を上書きしていた。環境変数が `light` / `dark` のときだけ上書きし、
未設定なら検出済みの値を維持するようにした。

Ghostty も実際のテーマが Dawn なので `env = TERM_BACKGROUND=light` を設定する。
Kitty / Ghostty とも、既存シェルの環境は設定再読込では書き換わらない。設定反映後に
新しいタブまたはウィンドウを作る必要がある。

根拠は Neovim 0.12.5 の `runtime/lua/vim/_core/defaults.lua`。`ttyfast` のとき
`OSC 11 ; ?` と DSR を送り、応答の RGB 輝度が 0.5 未満なら dark、それ以外なら light
として、ユーザー設定の読み込み前に最大 100 ms 待つ。

## 2026-08-25

### Dawn の判定と検索ハイライトを統一

- `.config/kitty/kitty.conf`
- `.config/kitty/light.conf`
- `.config/nvim/lua/plugins/visual.lua`

通常 Kitty を Rosé Pine Dawn と `TERM_BACKGROUND=light` の組み合わせに統一した。
Neovim は `TERM_BACKGROUND=light` なら Dawn、それ以外なら Moon を選ぶため、背景だけ
Dawn に変えて環境変数を dark のままにすると、透明な Neovim が Moon の文字色を使う。

Kitty の theme include より後ろに書いた色は theme を上書きする。独自の
`selection_background #DA70D6` などは Dawn の palette 外だったため、選択色と cursor
色は theme 側を正とした。通常設定が Dawn を読むようになった後も `light.conf` と
`slide.conf` から Dawn を再 include すると、kitty 0.48.2 は同じ読み込みツリー内の
重複を `RecursiveInclude` として設定警告にするため、派生設定から重複 include を外した。
`light.conf` は「Launch white in kitty」用なので、壁紙に左右されないよう
`background_opacity 1` を明示する。

Neovim の Rosé Pine は highlight override の省略属性を既定 group から継承する。
`Search = { bg = "foam", fg = "base" }` は上流の `blend = 20` も継承し、実効色の
コントラストが Dawn で約 1.22:1、Moon で約 1.60:1 になっていた。検索文字は
`gold` 背景と `text` 前景に変更し、現在位置の `IncSearch` は `inherit = false` で
blend や link の意図しない継承を止めた。
