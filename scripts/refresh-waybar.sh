#!/bin/env bash

if pgrep -x waybar >/dev/null; then
    # Try soft reload
    killall -SIGUSR2 waybar
    sleep 0.5
    # If still running and didn't refresh, hard restart
    if pgrep -x waybar >/dev/null; then
        killall -q waybar
        while pgrep -x waybar >/dev/null; do
            sleep 0.2
        done
        waybar & disown
    fi
else
    waybar & disown
fi
