#!/usr/bin/env bash

x_delta=0
y_delta=4

case "$1" in
up | u) y_delta=-4 ;;
down | d) y_delta=4 ;;
left | l) x_delta=-4 ;;
right | r) x_delta=4 ;;
esac

for _ in {1..14}; do
  wlrctl pointer scroll "$y_delta" "$x_delta"
  sleep 0.003
done
