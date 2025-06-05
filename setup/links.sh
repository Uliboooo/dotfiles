#!/bin/bash

links() {
    config_path=$HOME/.config
    
    ln -fs "${1}"/git/.gitconfig $HOME/.config/git/config
    ln -fs "${1}"/nano/.nanorc $HOME/.config/nano/nanorc
    ln -fs "${1}"/nvim $HOME/.config/nvim
    ln -fs "${1}"/starship $config_path/starship.toml
    ln -fs "${1}"/zed/settings.json $config_path/zed/settings.json
    ln -fs "${1}"/zsh/.zshrc $config_path/.zshrc
    ln -fs "${1}"/.vimrc $config_path/.vimrc
}
