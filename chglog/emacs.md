# Emacs

Emacs daemon から作る GUI frame と child frame の挙動に関する記録。

## 2026-08-14

### Evil normal state の C-x を数値 decrement に戻す

ファイル選択は insert state で行う運用に合わせ、normal state の `C-x` を
`evil-numbers/dec-at-pt` に戻す。`C-x C-f` などの Emacs 標準 prefix は insert state
で利用する。

### ThinkPad 固有の posframe サイズ調整を撤回

対象: `.config/emacs/init.el`

selinoir の内蔵画面で `vertico-posframe` が極小になる問題に対し、font-spec と
min-width / min-height による調整を試したが、PGTK のメモリ消費を悪化させたため撤回
した。selipaq で正常な中央 floating 表示を優先し、元の固定 width 100 / height 20 に
戻す。selinoir 固有の表示サイズ問題は当面扱わない。

### Evil normal state でも C-x prefix を保持する

対象: `.config/emacs/init.el`, `README/Emacs.md`, `README/Docs/EMACS_config.md`

`evil-normal-state-map` の `C-x` を `evil-numbers/dec-at-pt` に割り当てると、単独キーだけ
でなく `C-x C-f`、`C-x d`、`C-x b`、`C-x g` などの標準 prefix 全体が遮断される。
数値 decrement の割り当てを削除し、`C-x` は標準 prefix のまま使う。Dired は leader
からも `SPC d` (`dired-jump`) で現在位置を開けるようにする。

## 2026-08-13

### vertico-posframe で固定 width / height のピクセル換算を避ける

対象: `.config/emacs/init.el`

ThinkPad の画面では、daemon から作成した `vertico-posframe` が約 100 x 40 px の極端に
小さい表示になった。`posframe-20260527.857` の `posframe--set-frame-size` は width と
height が両方指定されると、`default-font-width` / `default-line-height` を掛けて
`set-frame-size` の pixelwise 引数へ渡す。この値は child frame ではなく daemon の初期
非 GUI frame から取得されることがあり、実質 1 x 2 px の文字寸法で計算される。

`vertico-posframe-font` に省略形の `"Monaspace Radon Var-13"` を渡す方法では、PGTK の
child frame が末尾の 13 を期待する point size として扱わず、文字自体も極小になった。
フォントは `font-spec` の `:size 13.0` で単位を曖昧にせず指定する。

width / height は `nil` のままにして min-width / min-height のみ指定する。これにより
`fit-frame-to-buffer` が実際の graphical child frame を測る経路へ入り、最低 60 桁 x
12 行を確保する。設定変更後、既に生成済みの posframe は再利用されるため、daemon の
再起動が必要。
