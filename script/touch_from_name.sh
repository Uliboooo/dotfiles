#!/bin/bash

input=$(cat)

result=$(echo "$input" | xargs | sed 's/ /-/g')

if [ -n "$result" ]; then
    touch "${result}"
    echo "File created: ${result}"
else
    echo "Error: Input is empty."
fi
