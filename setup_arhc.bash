#! /bin/bash
sudo pacman -Syu git vi vim neovim zsh starship helix zig zls go gopls llvm lldb ghostty eza ripgrep htop clang jq sbcl hyprland wofi base-devel

UserName=${SUDO_USER:-$USER}
chsh -s $(which zsh) $UserName

git clone https://github.com/uliboooo/dotfiles ~/dotfiles
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

ln -fs $HOME/dotfiles/usr/.zshrc ~/.zshrc
ln -fs $HOME/dotfiles/usr/.tmux.conf ~/.tmux.conf

mkdir -p $HOME/.config
# remove old config and create and put new configs
rm -rf $HOME/.config/zed
ln -fs $HOME/dotfiles/usr/.config/zed $HOME/.config/zed
rm -rf $HOME/.config/alacritty
ln -fs $HOME/dotfiles/usr/.config/alacritty $HOME/.config/alacritty
rm -rf $HOME/.config/nvim
ln -fs $HOME/dotfiles/usr/.config/nvim $HOME/.config/nvim
rm -rf $HOME/.config/stylua
ln -fs $HOME/dotfiles/usr/.config/stylua $HOME/.config/stylua
rm -rf $HOME/.config/hypr
ln -fs $HOME/dotfiles/usr/.config/hypr $HOME/.config/hypr
rm -rf $HOME/.config/waybar
ln -fs $HOME/dotfiles/usr/.config/waybar $HOME/.config/waybar
rm -rf $HOME/.config/wofi
ln -fs $HOME/dotfiles/usr/.config/wofi $HOME/.config/wofi
rm -rf $HOME/.config/helix
ln -fs $HOME/dotfiles/usr/.config/helix $HOME/.config/helix
rm -rf $HOME/.config/git
ln -fs $HOME/dotfiles/usr/.config/git $HOME/.config/git
rm -rf $HOME/.config/ghostty
ln -fs $HOME/dotfiles/usr/.config/ghostty $HOME/.config/ghostty

git clone https://aur.archlinux.org/yay.git
(cd yay && makepkg -si)

sudo -u $UserName bash -c '
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install zsh-autosuggestions zsh-syntax-highlighting
'

sudo -u $UserName bash -c '
cd ~
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
'

sudo -u "$UserName" tmux new-session -d -s default
sudo -u "$UserName" tmux source ~/.tmux.conf
