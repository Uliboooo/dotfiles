#!/bin/sh

sudo pacman -Syu --noconfirm
sudo pacman -S which --noconfirm
if ! type "zsh" > /dev/null 2>&1; then
    sudo pacman -S zsh --noconfirm
    echo "installing zsh..."
fi
if ! type "git" > /dev/null 2>&1; then
    sudo pacman -S git --noconfirm
fi
if ! type "brew" > /dev/null 2>&1; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if ! type "starship" > /dev/null 2>&1; then
    sudo pacman -S starship --noconfirm
fi

brew install zsh-autosuggestions zsh-syntax-highlighting

# echo "what's your name?"
current_shell=$(getent passwd $USER | cut -d: -f7 | rev | cut -d/ -f1 | rev)
if [ "$current_shell" != "zsh" ]; then
    chsh -s "$(which zsh)" "$USER"
fi

if [ -d "$HOME/dotfiles" ]; then
    BACKUP_DIR="$HOME/dotfiles_old_$(date +%Y%m%d-%H%M%S)"
    echo "Found existing $HOME/dotfiles. Backing it up to $BACKUP_DIR"
    mv "$HOME/dotfiles" "$BACKUP_DIR"
fi

git clone https://github.com/Uliboooo/dotfiles $HOME/dotfiles

sh "$HOME/dotfiles/setup/links.sh"
