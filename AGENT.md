# AGENT.md

seli の dotfiles / NixOS 構成。エージェント向けの作業ルール。

このファイルと [chglog.md](chglog.md) の目的は同じで、**次に来るエージェントの探索
コストを下げること**。ただし役割が違う。

- AGENT.md … 滅多に変わらない構造とルール。**基本的に増やさない**
- [chglog.md](chglog.md) … 索引。実体は [chglog/](chglog/) 以下にトピック別で置く。
  調べて分かった事実、この機固有の制約、駄目だった案。**知見はすべてこちらに溜める**

新しく分かったことを AGENT.md に書き足したくなったら、それは chglog/ に書く。
AGENT.md を編集するのは、ディレクトリ構成やビルド手順そのものが変わったときだけ。

chglog を**日付で分けない**のは、読むのが常に「これから触る領域」を軸にした
タイミングだから。日付分割だと目的の記述がどのファイルにあるか分からず、結局
全部開くことになる。日付は各ファイル内の見出しとして残す。

## リポジトリの地図

- `flake.nix` … エントリポイント。出力は 3 系統
  - `nixosConfigurations.desktop` … 実機 ThinkPad(ホスト名 `selitank`)
  - `darwinConfigurations.macbook` … nix-darwin (aarch64 前提。Intel Mac は非対応)
  - `homeConfigurations.seli` / `seli@x86_64-linux` / `seli@aarch64-darwin` …
    NixOS でないマシンで home-manager だけ使う場合
  - inputs のうち `wlmstr` `zathura-gui` `hyprpanopticon` はユーザ自身の GitHub リポジトリ。
    挙動が怪しいときは nixpkgs ではなくそちらを見る
- `hosts/desktop/configuration.nix` … このマシンの本体。lid の挙動、hibernate 用
  swapfile、fprintd、nixbuild.net リモートビルダーはここ。長いコメントが多いので
  触る前に該当箇所を読む
- `hosts/desktop/hardware-configuration.nix` … 自動生成。手で書き換えない
- `modules/common.nix` … CLI の最小セット。`modules/desktop.nix` … デスクトップ基盤
  (PipeWire / portal / polkit / gnome-keyring / greetd + ReGreet / fonts)。
  `modules/thinkpad.nix` … 現在は空で import もされていない
- `home/seli.nix` … home-manager のエントリ。`home/common_user.nix` が本体
  (パッケージ、`xdg.configFile` の symlink 定義、wallpaper の user timer)
- `.config/` … 素のドットファイル。反映のされ方は下記
- `README/` `Docs/` … 人間向けの手引き。`README/PaperDesign.md` が UI の配色・
  形状の規約で、Waybar / niri / SwayNC / greeter の見た目を触るなら必読
- `script/` … Waybar やキーバインドから呼ぶシェルスクリプト群

## 反映のされ方(間違えやすい)

- `.config/*` の大半は `mkOutOfStoreSymlink` で `~/dotfiles/.config/<name>` を直に
  指す(`home/common_user.nix:174` の `mkConfigLink`)。**編集は即反映で rebuild 不要**
- ただし `xdg.configFile` に列挙されたディレクトリだけが対象。**新しい
  `.config/<name>` を足したときは列挙に追加して rebuild しないと存在しないのと同じ**
- 例外として store 経由になるものがある。`.config/greetd/regreet.css` は
  `modules/desktop.nix` が `../.config/greetd/...` として読むので rebuild が要る
- `.config/zsh` は home-manager が `programs.zsh` で生成する側。`.zshrc`(リポジトリ
  直下)を non-nix マシンと共用しており、そちらを正としている
- `.config/fish` は fisher が書き込むため out-of-store。`programs.fish` は使わない
  (home-manager と config.fish の所有権が衝突する)

## 作業を始める前に chglog を読む

**調べ始める前に [chglog.md](chglog.md) の索引を読む。** この機の癖・既に却下された
案・上流の実装で確認済みの挙動はすべて chglog/ にある。読まずに調べ直すと、同じログ
を取り直したり、既に駄目だと分かっている案を提案したりする。

- 索引で当たりを付けて、触る領域のファイルを 1 つだけ開く。全部読む必要はない
  (それが分けてある理由)。ヒットしたエントリは「ハマりどころ」まで読む
- 当てが外れたら `grep -rn '<keyword>' chglog/` で横断する
  (`hibernate` `greetd` `keyring` `wl-copy` など)
- 電源管理・ログイン・Wayland クリップボード周りは特に地雷が多い。ここを触るなら
  該当ファイルを読み終えるまで手を動かさない
- chglog に書いてある結論と違う結論に至ったときは、黙って上書きせず、何が変わった
  のかをユーザに確認する

## 作業の進め方

- 変更したら `nixos-rebuild build --flake .#desktop` で通ることを確認する。
  `switch` は sudo にパスワードが要るのでユーザに任せる
- 評価だけ確かめたいときは CI と同じ 3 つが速い
  (`.github/workflows/nix-validate.yml`)
  - `nix flake check --system x86_64-linux`
  - `nix eval .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath`
  - `nix eval .#nixosConfigurations.desktop.config.home-manager.users.seli.home.activationPackage.drvPath`
- `home/` を触ったら macOS 側の評価も壊れていないか見る
  (`nix eval .#homeConfigurations."seli@aarch64-darwin".activationPackage.drvPath`)
- ビルド後の `./result` シンボリックリンクは消しておく
- ログイン周り(displayManager, PAM, LUKS)を触るときは、失敗するとログインできなく
  なる。世代ロールバックで戻せることを伝えた上で進める
- 回答は日本語で行う

## chglog への追記

設定を変更したら [chglog/](chglog/) の該当トピックのファイルに追記する。
**コミットとは別に必ず書く。** 作業中に分かったことは、AGENT.md ではなくここに足す。

判断基準は一つで、**次のエージェントが同じ場所を調べ直さずに済むか**。
`git log` と `git diff` を読めば分かることは書かない。

### 書くもの

- **調べて確定した事実**。上流の実装の挙動、既定値、探索パス、nixpkgs の attribute
  名など。可能なら根拠を添える(バージョンと `src/sysutil.rs:110-124` のような位置、
  `systemctl show ... -p Environment` のような確認コマンド)。ここが一番寿命が長い
- **この機固有の制約**。ハードウェアの癖や、他の設定との噛み合わせで生じる制限
- **試して駄目だった案と、駄目だと判断した根拠**。ログの要点を残す。次に同じ案を
  思いついたときに、再検証せずに切れるようにするのが目的
- **選択肢の中からそれを選んだ理由**。特に「一見もっと素直な方法」を採らなかった理由
- **ハマりどころ**。PATH、attribute 名の変更、パーサの癖、非同期・プロセス寿命など、
  次も同じ形で踏むもの
- **検証に使ったコマンドと結果**。「動くはず」ではなく実機で確かめた事実
- **確かめられなかったこと**も、その理由と共に書く(自動テストが原理的に無理など)

### 書かなくていいもの

- 変更内容そのものの逐条説明(diff を見れば分かる)
- そのセッション限りの試行錯誤の経過。結論と根拠だけに畳む
- 秘密情報(鍵、パスフレーズ、トークン)。UUID やデバイスパスは既にリポジトリ内に
  あるので可

### 形式

- 新しいものを上に。日付見出し `## YYYY-MM-DD` の下に `### <一行要約>` を並べる
- 既存のトピックに入らない変更は `chglog/<topic>.md` を新設し、chglog.md の索引に
  1 行足す。1 ファイルが読み通せなくなったら(目安 300 行)さらに割る。日付では割らない
- 複数トピックに跨る話は主トピックに本体を置き、もう一方からは 1 行でリンクする
- 各ファイルの冒頭に、そのトピックの動かない前提(S3 が無い、D&D は不可 等)を
  数行で書いておく。ファイルを開いた瞬間に効く情報はここに集める
- 各エントリの冒頭に触ったファイルを列挙する
- 結論を先に書き、根拠を後ろに置く。「ハマりどころ」は箇条書きで独立させる
- ログを引用するときは要点だけ。全文貼りはしない
- 既存エントリの結論を覆したときは、古いエントリを消さずに新しいエントリから
  「いつ・なぜ変わったか」を書いて繋ぐ。判断の履歴が残っていること自体が資料になる
- 日本語で書く
