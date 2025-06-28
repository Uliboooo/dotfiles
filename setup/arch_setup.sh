#!/bin/sh

sudo pacman -Syu --noconfirm
sudo pacman -S which --noconfirm
if ! type "zsh" > /dev/null 2>&1; then
    sudo pacman -S zsh --noconfirm
    echo "installing zsh..."
fi
if type "git" > /dev/null 2>&1; then
    sudo pacman -S git --noconfirm
fi

echo "what's your name?"
read name
current_shelll=$(getent passwd "$name" | cut -d: -f7 | rev | cut -d/ -f1 | rev)
if [ "$current_shelll" != "zsh" ]; then
    chsh -s $(which zsh) "$name"
fi

if [ -d "$HOME/dotfiles" ]; then
    rm -rf "$HOME/dotfiles"
fi

git clone https://github.com/Uliboooo/dotfiles $HOME/dotfiles

sh "$HOME/dotfiles/setup/links.sh"
