#!/bin/sh

sudo dnf -y update
sudo dnf -y install git tree sbcl vim neovim glow

[ -d "$HOME/dotfiles" ] && rm -rf "$HOME/dotfiles/"
git clone https://github.com/Uliboooo/dotfiles $HOME/dotfiles

config_list="git nano nvim starship wezterm zed zsh"
dot_path="$HOME/dotfiles"
config_path="$HOME/.config"

for t in $config_list; do
    ln -fs "$HOME/dotfiles/$t" "$HOME/.config/$t"
done

# ln -fs $HOME/dotfiles/git $config_path/git

NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [ -d "$HOME/.linuxbrew" ]; then
    eval "$($HOME/.linuxbrew/bin/brew shellenv)"
elif [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

brew install starship zsh-autosuggestions zsh-syntax-highlighting

