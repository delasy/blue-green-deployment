#!/usr/bin/env bash

set -ev

BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
REMOTE_CODE="$(< "$BASE_DIR/remote.sh")"
REMOTE_CODE="${REMOTE_CODE//\$INPUT_BLUE_PORT/$INPUT_BLUE_PORT}"
REMOTE_CODE="${REMOTE_CODE//\$INPUT_GREEN_PORT/$INPUT_GREEN_PORT}"
REMOTE_CODE="${REMOTE_CODE//\$INPUT_NAME/$INPUT_NAME}"

tmp_dir="${RUNNER_TEMP:-$TMPDIR}"

tar --exclude=.git -czf "$tmp_dir/$INPUT_NAME.tgz" "$INPUT_SOURCE"

if [ "$INPUT_PASSWORD" == '' ]; then
  remote="$INPUT_USERNAME@$INPUT_HOST"
else
  remote="$INPUT_USERNAME:$INPUT_PASSWORD@$INPUT_HOST"
fi

ssh_args=('-o' 'StrictHostKeyChecking=no')

if [ "$INPUT_PRIVATE_KEY" != '' ]; then
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  printf '%s' "$INPUT_PRIVATE_KEY" > "$HOME/.ssh/$INPUT_NAME"
  chmod 600 "$HOME/.ssh/$INPUT_NAME"
  ssh_args+=('-i' "$HOME/.ssh/$INPUT_NAME")
fi

scp "${ssh_args[@]}" -P "$INPUT_PORT" "$tmp_dir/$INPUT_NAME.tgz" "$remote:$INPUT_NAME.tgz"
ssh "${ssh_args[@]}" -p "$INPUT_PORT" "$remote" 'bash -s' <<< "$REMOTE_CODE"
