#!/bin/bash

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install
nvm use

args=("$@")

for s in "${args[@]}"; do
  res=$(npx oh-my-logo "${s}" --filled --block-font chrome)

  # ANSIエスケープコードを除去してから空行を削除
  res=$(echo "$res" |
    tr -d '\r' |
    sed 's/\x1b\[[0-9;?]*[mGKHFJA-Za-z]//g' |
    sed '/^[[:space:]]*$/d')

  max=0

  while IFS= read -r line; do
    len=${#line}
    if ((max < len)); then
      max=$len
    fi
  done <<<"$res"

  border_width=$((max + 5))

  printf '%.0s#' $(seq 1 $border_width)
  printf '\n'

  while IFS= read -r line; do
    len=${#line}
    padding=$((max - len + 1))
    printf "# %s" "$line"
    printf '%.0s ' $(seq 1 $padding)
    printf " #\n"
  done <<<"$res"

  printf '%.0s#' $(seq 1 $border_width)
  printf '\n\n'
done
