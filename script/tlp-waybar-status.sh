#!/bin/bash

# Get current TLP power profile (TLP 1.9+)
get_tlp_profile() {
  PROFILE=$(
    tlp-stat -s \
      | awk -F'=' '/Power profile/ {
          gsub(/^[ \t]+|[ \t]+$/, "", $2)
          split($2, a, "/")
          print a[1]
        }'
  )

  case "$PROFILE" in
    performance)
      echo '{"text":"PERF","tooltip":"Performance","class":"performance"}'
      ;;
    balanced)
      echo '{"text":"BAL","tooltip":"Balanced","class":"balanced"}'
      ;;
    power-saver)
      echo '{"text":"ECO","tooltip":"Power Saver","class":"powersaver"}'
      ;;
    *)
      echo '{"text":"UNKN","tooltip":"Unknown","class":"unknown"}'
      ;;
  esac
}

get_tlp_profile

