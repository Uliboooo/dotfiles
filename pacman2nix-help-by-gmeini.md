2025/12/21

Home Manager 用の設定ファイルを etc/home-manager/ に作成しました。

  構成

   1 dotfiles/
   2 └── etc/
   3     └── home-manager/
   4         ├── flake.nix
   5         └── home.nix

  適用方法 (Arch Linux 上)

  まだ Nix と Home Manager を導入していない場合は、以下の手順で適用できます。

   1. Nix のインストール (まだの場合):

   1     sh <(curl -L https://nixos.org/nix/install) --daemon

   2. Experimental Features (Flakes) の有効化:
      ~/.config/nix/nix.conf または /etc/nix/nix.conf に以下を追記します。
   1     experimental-features = nix-command flakes

   3. Home Manager の適用:
      dotfiles ディレクトリ内で以下のコマンドを実行します。

   1     # 初回実行時 (Home Manager自体をインストールしつつ適用)
   2     nix run home-manager/master -- switch --flake ./etc/home-manager#coyuki
   3
   4     # 2回目以降 (home-managerコマンドが使えるようになったら)
   5     home-manager switch --flake ./etc/home-manager#coyuki

  これで、Arch Linux のシステム環境（pacman）とは独立して、Nix でパッケージを管理できるようになります。
