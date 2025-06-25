#!/bin/sh

sudo dnf -y update
sudo dnf -y install git tree sbcl

git clone https://github.com/Uliboooo/dotfiles $HOME/
sh ./links.sh
source $HOME/.zshrc

NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

brew install starship

