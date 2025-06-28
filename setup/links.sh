#!/bin/sh

mkdir -p "$HOME/.config"

list="alacritty fastfetch git nano nvim starship wezterm zed"

for i in $list ;do
    ln -fs "$HOME/dotfiles/usr/.config/$i" "$HOME/.config/$i"
done

# ln -fs "$HOME/dotfiles/usr/.config" "$HOME/.config"
ln -fs "$HOME/dotfiles/usr/.zshrc" "$HOME/.zshrc"

