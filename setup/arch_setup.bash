sudo pacman -Syu --noconfirm
sudo pacman which --noconfirm
if type "zsh" > /dev/null 2>&1; then
    sudo pacman -S zsh --noconfirm
    echo "inslling zsh..."
fi
if type "git" > /dev/null 2>&1; then
    sudo pacman -S git --noconfirm
fi

sudo pacman -S which --noconfirm
echo "what's your name?"
read name
if [getent passwd $name | cut -d: -f7 | rev | cut -d/ -f1 | rev != "zsh"]; then
    chsh -s $(which zsh)
fi

if [ -d "$HOME/dotfiles" ]; then
    rm -rf "$HOME/dotfiles"
fi

git clone https://github.com/Uliboooo/dotfiles $HOME/dotfiles

dot_path="$HOME/dotfiles"

ln -fs $dot_path/usr/.config $HOME/.config
ln -fs $dot_path/usr/.zshrc $HOME/.zshrc

