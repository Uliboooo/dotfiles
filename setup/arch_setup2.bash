sudo pacman -S git tree neovim vim --noconfirm

# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# curl https://zed.dev/install.sh | sh -s -- -y
mkdir -p $HOME/.config/git
mkdir -p $HOME/.config/nano
# mkdir -p $HOME/.config/zed
mkdir -p $HOME/.config/nvim

self_dir=$(dirname $(cd $(dirname $0); pwd))

ln -fs "$self_dir"/git/.gitconfig $HOME/.config/git/config
ln -fs "$self_dir"/nano/.nanorc $HOME/.config/nano/nanorc
ln -fs "$self_dir"/nvim $HOME/.config/nvim
ln -fs "$self_dir"/starship $HOME/.config/starship.toml
# ln -fs "$self_dir"/zed/settings.json $HOME/.config/zed/settings.json
ln -fs "$self_dir"/zsh/.zshrc $HOME/.zshrc
ln -fs "$self_dir"/.vimrc $HOME/.vimrc

curl -sS https://starship.rs/install.sh | sh -s -- -y
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
