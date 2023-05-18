#!/bin/bash

FILE_NAME=$(date "+%Y-%m-%d")
ROOT_PATH=~/.journal
FULL_FILE="$ROOT_PATH/$FILE_NAME.md"

[[ ! -d  $ROOT_PATH ]] && mkdir $ROOT_PATH

if [[ ! -f  $FULL_FILE ]]; then
  cat > "$FULL_FILE" <<EOL
# $FILE_NAME

## TODO

### Work
- []

### Personal
- []

## Happenings

## For tomorrow
EOL
fi

nvim "$FULL_FILE"
