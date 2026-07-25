# AGENT.md

seli の dotfiles / NixOS 構成。エージェント向けの作業ルール。

## chglog.md への記録

設定を変更したら [chglog.md](chglog.md) に追記する。**コミットとは別に必ず書く。**

`git log` を見れば「何を変えたか」は分かる。chglog.md に書くのは `git diff` から
読み取れないこと、つまり**なぜそうしたか**と**試して駄目だったこと**。

### 書くもの

- 変更の意図。特にハードウェア固有の理由(この機は ThinkPad E14 Gen 6 / AMD /
  Modern Standby で、s2idle しか無い・amdgpu が hibernate と競合する等の癖がある)
- 試して駄目だった案と、その判断根拠になったログやコマンド出力。同じことを再挑戦
  するときに、また同じ穴に落ちないようにするのが主目的
- ハマりどころ。PATH が通っていない、nixpkgs の attribute 名が変わった、設定ファイル
  のパーサに癖がある、といった次回も踏むもの
- 検証に使ったコマンドと結果。「動くはず」ではなく実機で確かめた事実を残す

### 書かなくていいもの

- 変更内容そのものの逐条説明(diff を見れば分かる)
- 一時的な作業メモ、そのセッション限りの試行錯誤
- 秘密情報(鍵、パスフレーズ、トークン)。UUID やデバイスパスは既にリポジトリ内に
  あるので可

### 形式

- 新しいものを上に。日付見出し `## YYYY-MM-DD` の下に `### <一行要約>` を並べる
- 各エントリの冒頭に触ったファイルを列挙する
- ログを引用するときは要点だけ。全文貼りはしない
- 日本語で書く

## この構成について

- `flake.nix` … エントリポイント。`nixosConfigurations.desktop`(ホスト名 selitank)
- `hosts/desktop/` … ホスト固有。`configuration.nix` と `hardware-configuration.nix`
- `modules/` … システム共通のモジュール。`desktop.nix` がデスクトップ基盤
- `home/` … home-manager。`common_user.nix` が本体
- `.config/` … 素のドットファイル。home-manager が /nix/store 経由で symlink する
  ので、編集しても `nixos-rebuild` するまで反映されない

## 作業上の注意

- 変更したら `nixos-rebuild build --flake .#desktop` で通ることを確認する。
  `switch` は sudo にパスワードが要るのでユーザに任せる
- ビルド後の `./result` シンボリックリンクは消しておく
- ログイン周り(displayManager, PAM, LUKS)を触るときは、失敗するとログインできなく
  なる。世代ロールバックで戻せることを伝えた上で進める
- 回答は日本語で行う
