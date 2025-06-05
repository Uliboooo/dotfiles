#!/bin/bash

load_scripts() {
  local dir="$1"
  for file in "$dir"/*.sh; do
    [ -f "$file" ] && source "$file"
  done
}
set -e

dir=$(pwd)

if [ $(basename $dir) = "dotfiles" ]; then
    echo "start setup"
else
    echo "dir error: current dir isn't \`dotfiles\`. please cd \`dotfiles\`."
    false
fi

load_scripts $dir/setup
sh $dir/setup/update.sh

ab_install "zsh"
sudo chsh -s /bin/zsh $(basename $HOME)

sh $dir/setup/installs.sh
sh $dir/setup/links.sh
