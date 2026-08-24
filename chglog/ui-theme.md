# Kitty / Neovim のテーマ

Kitty は `TERM_BACKGROUND` を子プロセスへ渡し、Neovim はその値から起動時の
Rosé Pine variant を選ぶ。Kitty の実際の背景とこの値は必ず揃える。

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
