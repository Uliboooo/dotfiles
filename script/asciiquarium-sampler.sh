#!/usr/bin/env bash

# Render Asciiquarium inside sampler by running it in a tmux session
# and capturing the pane contents.

SESSION="sampler-aquarium"
WIDTH="${1:-40}"
HEIGHT="${2:-18}"

if ! command -v asciiquarium >/dev/null 2>&1; then
  echo "Installed: no"
  echo "Add package and rebuild Home Manager."
  exit 0
fi

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux: not installed"
  echo "Add package and rebuild Home Manager."
  exit 0
fi

if tmux has-session -t "$SESSION" 2>/dev/null; then
  pane_state=$(tmux list-panes -t "$SESSION" -F '#{pane_dead}' 2>/dev/null | head -1)
  if [[ "$pane_state" == "1" ]]; then
    tmux kill-session -t "$SESSION"
  fi
fi

if tmux has-session -t "$SESSION" 2>/dev/null; then
  pane_size=$(tmux display -pt "$SESSION" "#{pane_width} #{pane_height}" 2>/dev/null)
  if [[ "$pane_size" != "$WIDTH $HEIGHT" ]]; then
    tmux kill-session -t "$SESSION"
  fi
fi

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux new-session -d -s "$SESSION" -x "$WIDTH" -y "$HEIGHT" "asciiquarium"
  tmux set-option -t "$SESSION" status off
fi

tmux capture-pane -p -t "$SESSION" -S "-${HEIGHT}"
