#!/bin/bash

FILE_NAME=$(date "+%Y-%m-%d")
ROOT_PATH=~/.journal
FULL_FILE="$ROOT_PATH/$FILE_NAME.md"

[[ ! -d  $ROOT_PATH ]] && mkdir $ROOT_PATH

if [[ ! -f  $ROOT_PATH/$FILE_NAME ]]; then
  cat > "$FULL_FILE" <<EOL
  # $FILE_NAME

  ## TODO
  - []

  ## Happenings

  ## For tomorrow
EOL
fi

nvim "$FULL_FILE"
