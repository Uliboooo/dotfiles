# chglog

設定変更の記録。「なぜそうしたか」と「試して駄目だったこと」を残すのが目的で、
何を変えたかだけなら `git log` で足りる。新しいものを上に追記する。

書き方は [AGENT.md](AGENT.md) を参照。

---

## 2026-07-25

### 音声再生中はロックと hibernate を撃たない

- `.config/hypr/hypridle.conf`
- `modules/desktop.nix` (`jq` を systemPackages へ)

hypridle はコンポジタの `ext_idle_notifier_v1` しか見ず、キー/マウスの無操作だけで
判定する。アイドル抑止(`zwp_idle_inhibit_manager_v1`, niri は実装済み)は
`ignore_inhibit: false` なので尊重されるが、音声のみの再生で抑止を取るアプリは
ほとんど無い(ブラウザが取るのは動画再生時)。結果、音楽を流したまま放置すると
10 分でロック、30 分で hibernate して再生が止まっていた。

PipeWire に再生中ストリームがあるかで判定する。ALSA の
`/proc/asound/card*/pcm*p/sub*/status` を見る手もあるが、**Bluetooth 出力は ALSA を
通らないので検出できない**。この機は Bluetooth を使うため PipeWire 側を見る。

```
pw-dump | jq -e 'any(.[]; .info.props."media.class"=="Stream/Output/Audio" and .info.state=="running")'
```

再生中 exit 0 / 非再生 exit 1 を実機で確認済み。pw-dump が落ちた場合は非再生扱いに
ならず「ロックする」側に倒れる(fail-safe)。

減光(8 分)と画面オフ(10 分)は再生中でも従来どおり効かせる。パネルを消しても再生は
続くので省電力上むしろ好都合。

### 蓋を閉じたときの hibernate は断念、suspend に差し戻し

- `hosts/desktop/configuration.nix`

`/sys/power/mem_sleep` が `[s2idle]` のみ(Modern Standby, S3 無し)なので、蓋を閉じて
持ち運ぶ間 suspend では電力を垂れ流す。S4 なら実質ゼロになるため
`HandleLidSwitch = "hibernate"` を試したが、**蓋起因の hibernate は amdgpu と競合して
ハングする**ため戻した。

```
16:03:18 Lid closed / Hibernating...
16:03:19 Lid opened               ← 凍結処理中(6 秒超)に開け直した
16:03:26 soft lockup, Tainted: [D]=DIE
16:03:54 amdgpu_dm_atomic_commit_tail → amdgpu_bo_unpin → ttm_bo_unpin
         _raw_spin_lock で停止 → ハング → 強制電源断
```

イメージが書かれないので次回は cold boot(`PM: Image not found (code -22)`)になり
セッションが飛ぶ。同日 16:00 の試行も `Lid opened` と同時刻で中断していた。

一方 hypridle の 30 分アイドル hibernate は蓋イベントを伴わないため成功実績がある
(7/24 23:46 に 7391040 kbytes 書き込み → 翌 00:05 に resume 成功)。長時間放置の省電力
は hypridle 側に任せ、蓋は 3 つとも suspend に留める。

再挑戦するなら amdgpu の atomic commit と hibernate 凍結の競合が直っているかを先に
見ること。

### hypridle にアイドル用リスナーを追加

- `.config/hypr/hypridle.conf`
- `modules/desktop.nix` (`brightnessctl` を systemPackages へ)

従来リスナーは 30 分 hibernate の 1 個だけで、減光も画面オフもロックも無かった。
離席しても 30 分間フル輝度で点きっぱなしになり、GNOME(10 分で画面オフ、15 分で
suspend)より明確に電力を食っていた。8 分で減光 / 10 分でロック + DPMS off を追加。

実装上の落とし穴が 2 つ:

- **`$NIRI_SOCKET` は使えない**。hyprlang が `$識別子` を自前の変数として食う。
  `$(...)` は識別子でないので無事。niri / Hyprland の判別は `pidof niri` で行う。
- **hypridle.service の PATH は最小限**(hyprland/hyprlock/procps/coreutils/findutils/
  grep/sed/systemd のみ)。`niri` も `hyprctl` も `brightnessctl` も `jq` も入らないので
  `/run/current-system/sw/bin` を絶対パスで叩く。そのため各コマンドは
  `environment.systemPackages` 側に置く必要がある(ユーザプロファイルでは駄目)。

### GDM をやめて greetd + tuigreet に

- `modules/desktop.nix`

GDM はログイン後も greeter セッションが常駐し続ける(gnome-shell 一式で RSS 約
946MB)。さらにその `gsd-media-keys` が `handle-power-key` / `handle-suspend-key` /
`handle-hibernate-key` を block モードで握って niri 側の power-key 処理と競合し、
`gnome-shell` と `gsd-power` が sleep の delay inhibitor を持つのでサスペンド開始も
遅れていた。tuigreet は TTY 上で動きログイン後に終了するのでいずれも起きない。

- `--sessions /run/current-system/sw/share/wayland-sessions` は必須。tuigreet の既定の
  探索先は `/usr/share/wayland-sessions` で NixOS には無く、セッション一覧が空になる。
- `security.pam.services.greetd.enableGnomeKeyring = true` を忘れないこと。これが無いと
  login キーリングが解錠されず、gcr-ssh-agent が `~/.ssh/id_ed25519` のパスフレーズを
  取り出せずに GitHub への SSH が固まる。
- nixpkgs 側で **`greetd.tuigreet` は存在せず、トップレベルの `pkgs.tuigreet`**(0.9.1)。
