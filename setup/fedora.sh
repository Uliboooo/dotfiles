#!/bin/sh


sudo dnf -y update
sudo dnf install -y wihch



if ! type "zsh" > /dev/null 2>&1; then
    sudo pacman -S zsh --noconfirm
    echo "installing zsh..."
fi

git clone https://github.com/Uliboooo/dotfiles $HOME/dotfiles

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


# set -e
#
# sudo dnf -y update
# sudo dnf -y install zsh git tree sbcl vim neovim glow
#
# sudo chsh -s "$(which zsh)" "$(logname)"
# exec zsh
#
# [ -d "$HOME/dotfiles" ] && rm -rf "$HOME/dotfiles/"
# git clone https://github.com/Uliboooo/dotfiles $HOME/dotfiles
#
# config_list="git nano nvim starship wezterm zed"
# dot_path="$HOME/dotfiles"
# config_path="$HOME/.config"
#
# # for t in $config_list; do
# #     ln -fs "$HOME/dotfiles/$t" "$HOME/.config/$t"
# #     echo "linked $t"
# # done
# mkdir -p "$config_path"
#
# for t in $config_list; do
#     src="$dot_path/$t"
#     dest="$config_path/$t"
#     if [ -e "$src" ] || [ -d "$src" ]; then
#         ln -fs "$src" "$dest"
#         echo "linked $t"
#     else
#         echo "skip $t: $src not found"
#     fi
# done
#
# ln -fs $HOME/dotfiles/zsh/.zshrc $HOME/.zshrc
#
# # ln -fs $HOME/dotfiles/git $config_path/git
#
# NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#
# if [ -d "$HOME/.linuxbrew" ]; then
#     eval "$($HOME/.linuxbrew/bin/brew shellenv)"
# elif [ -d "/home/linuxbrew/.linuxbrew" ]; then
#     eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# fi
#
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
#
# brew install starship zsh-autosuggestions zsh-syntax-highlighting
#
