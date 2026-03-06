#!/bin/bash

echo "logout? enter/esc"
read -rsn1 char
case "$char" in
  "")
    hyprctl dispatch exit
    ;;
  *)
    echo "canceled"
    ;;
esac

