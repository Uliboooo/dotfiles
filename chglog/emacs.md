# Emacs

Emacs daemon から作る GUI frame と child frame の挙動に関する記録。

## 2026-08-19

### KDLを専用major modeでhighlightする

`.kdl`が`conf-javaprop-mode`へ誤認され、quote以降の文字列範囲が崩れていたため、
`kdl-mode`へ関連付ける。

### GUI Emacsのmouse cursor themeをGTKと統一する

PGTK Emacsが参照するGTK設定を`Bibata-Modern-Ice` size 20へ設定し、Niriの
`XCURSOR_THEME`と一致させる。GTKだけAdwaitaへ戻る状態を防ぐ。

### point位置のOrg markupを表示する

`org-appear-mode`をOrg bufferで有効にする。通常時はlinkや強調記号を整形表示し、pointを
置いた要素だけ`[[URL][label]]`などの編集可能なsource表現へ戻す。
Org parserの前提に合わせ、Org bufferの`tab-width`は共通値の2ではなく8に固定する。

### mode-lineにNyancatのposition barを追加

Doom Modelineの`buffer-position` segmentが対応している`nyan-mode`を有効にする。
Nyancatはbuffer内のpoint位置を示す。常時animationは無効にし、再描画負荷を抑える。

### nix developのtoolをbufferごとに利用する

`envrc-global-mode`を有効にし、`.envrc`で`use flake`したprojectではdirenvが生成する
環境をbuffer-localな`process-environment`と`exec-path`へ反映する。Emacs daemon全体の
PATHを汚さず、ApheleiaとEglotがproject内のformatter・language serverを利用できる。
dotfilesのdefault dev shellにも`typst`、`typstyle`、`tinymist`を追加する。

### Typstの保存時formatを有効化

Apheleia標準の`typst-ts-mode -> typstyle`対応を利用し、Home Managerの共通パッケージへ
`typstyle`を追加する。`.typ` bufferは保存時に非同期formatされる。

### 下部terminalのtoggleを追加

`SPC t t` で現在frame下部のside windowにEat terminalを表示・非表示する。同じbufferと
shell processを再利用し、terminalへ移動したときはEvil insert stateへ入る。組み込み
`term`ではfish promptのOSC sequenceが文字として露出したため、xterm互換性の高いEatを使う。

## 2026-08-15

### capture の Note は恒久ノートへ直接保存する

対象: `.config/emacs/init.el`, `.config/emacs/README.md`

`n` の Note capture は一時的なタスク Inbox を経由せず、`~/org/notes.org` へ直接追記
する。`t` の Todo capture は引き続き `~/org/inbox.org` を使う。

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
