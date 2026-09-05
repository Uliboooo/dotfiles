# キーボード

ThinkPad 固有の Ctrl / Alt 入れ替えは `keyd` で行う。外付けキーボード自身の配列とは
独立なので、必要な機器は keyd の対象から明示的に除外する。

## 2026-09-04

### Rainy 75 を ThinkPad の Ctrl / Alt 入れ替えから除外

触ったファイル: `hosts/thinkpad/configuration.nix`, `chglog.md`, `chglog/keyboard.md`

Rainy 75 の input device ID は `320f:5055` (`RDR Rainy 75 Keyboard`)。ThinkPad 構成の
`services.keyd.keyboards.default` は `[ids] *` で全キーボードに Ctrl / Alt 入れ替えを
適用していたため、Rainy 75 にも変換がかかっていた。

keyd 2.6.0 はワイルドカードの `[ids]` で `-<id>` を除外指定として扱う。このため
`[ "*" "-320f:5055" ]` とし、内蔵 `AT Translated Set 2 keyboard` などの既存対象は
維持しつつ Rainy 75 だけを除外した。ID は `/proc/bus/input/devices` と
`udevadm info --query=property --path=/sys/class/input/event19/device` で確認した。
