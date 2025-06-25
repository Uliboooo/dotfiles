#!/bin/sh

# **wip**
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
DOT_DIR="$(dirname $SCRIPT_DIR)"
ln -fs $DOT_DIR $HOME/.config
