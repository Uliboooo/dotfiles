#!/bin/bash

set -e

dir=$(pwd)

if [ $(basename "${dir}") = "dotfiles" ]; then
    echo "start setup"
else
    echo "dir error: current dir isn't \`dotfiles\`. please cd \`dotfiles\`."
    false
fi

# "${1}"
source "${dir}"/setup/abstract_install.sh

sh "${dir}"/setup/update.sh

ab_install "zsh"
sudo chsh -s /bin/zsh $(basename $HOME)

sh "${dir}"/setup/installs.sh
sh "${dir}"/setup/links.sh
