#!/bin/bash

find ~/Builds/Minimal-Arch-Setup/ -type f -name "*.sh" -exec sh -c '
  FILE_BASENAME=$(basename "$1")
  if chmod +x "$1"; then
    printf "Made executable: %s\n" "$FILE_BASENAME"
  else
    printf "Failed: %s\n" "$FILE_BASENAME"
  fi
' _ {} \;
