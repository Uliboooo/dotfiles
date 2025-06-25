#!/bin/sh

sudo dnf -y update
sudo dnf -y install git tree sbcl vim neovim

git clone https://github.com/Uliboooo/dotfiles $HOME/

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
DOT_DIR="$(dirname $SCRIPT_DIR)"
ln -fs $DOT_DIR $HOME/.config

source $HOME/.zshrc

NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

brew install starship

