#!/bin/bash

source ./abstract_install.sh
ab_installs "git" "tree" "neovim" "vim"

curl -sS https://starship.rs/install.sh | sh -s -- -y
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
curl -f https://zed.dev/install.sh | sh -s -- -y
