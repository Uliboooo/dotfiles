# systemd user timer

Home Manager の `systemd.user` で、ユーザー単位の定期処理を管理する。

## 2026-08-13

### org リポジトリの同期は専用 oneshot service から実行する

触ったファイル: `home/common_user.nix`

`~/org` はディレクトリ自体を Git リポジトリとして扱い、起動 1 分後、その後は前回の
実行から 5 分ごとに `git pull` する。`git add .` 後の index に差分がある場合だけ、
変更ファイルの一覧を `org mode chagens: path/to/file,another/file` 形式で commit message
に含め、その後 `git push` する。変更がない回にも push するため、直前の実行で push
だけ失敗した場合は次回に再送できる。

ハマりどころ:

- `git diff --quiet` では未追跡ファイルを検出できない。先に `git add .` し、
  `git diff --cached --quiet` で commit の要否を判定する。
- `~/org/.git` が無い場合は成功扱いで黙ってスキップせず、設定ミスが journal に残る
  よう service を失敗させる。
