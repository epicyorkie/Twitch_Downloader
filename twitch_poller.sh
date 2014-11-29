#!/bin/bash

# Dependencies: livestreamer, Curl
#
# Description: Polls twitch channel status and downloads stream if user is online

Usage="$0 <space-separated list of twitch channels>"

Channels=($@)

Interval="5" # polling interval in seconds

if [[ -z "$Channels" ]]; then
  echo "Error: No channels provided"
  echo "Usage: $Usage"
  exit 1
fi

while true; do
  for i in ${Channels[@]}; do
    StreamData="$(curl -s  "https://api.twitch.tv/kraken/streams/$i")"
    if echo "$StreamData" | grep -q '"status":404'; then # 404 Error
      echo "Error: $i does not exist."
      break 2
    elif echo "$StreamData" | grep -q '"stream":null'; then # Channel offline
      echo "$i is offline."
    else # Channel online
      echo "$i is live. Downloading stream..."
      livestreamer "http://www.twitch.tv/$i" best -o "$(date +"${i}_TwitchVOD_%Y-%m-%d_%H%M%S.mp4")"
    fi
  done
  sleep "$Interval"
done
