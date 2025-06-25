#!/bin/sh

sudo dnf -y update
sudo dnf -y install git tree sbcl vim neovim glow

git clone https://github.com/Uliboooo/dotfiles $HOME/dotfiles

ln -fs $HOME/dotfiles $HOME/.config

# source $HOME/.zshrc

NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

brew install starship

