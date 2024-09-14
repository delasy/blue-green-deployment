#!/usr/bin/env bash

set -ev

BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
REMOTE_CODE="$(< "$BASE_DIR/remote.sh")"
REMOTE_CODE="${REMOTE_CODE//\$INPUT_BLUE_PORT/$INPUT_BLUE_PORT}"
REMOTE_CODE="${REMOTE_CODE//\$INPUT_GREEN_PORT/$INPUT_GREEN_PORT}"
REMOTE_CODE="${REMOTE_CODE//\$INPUT_NAME/$INPUT_NAME}"

tmp_dir="${RUNNER_TEMP:-$TMPDIR}"

tar --exclude=.git -czf "$tmp_dir/$INPUT_NAME.tgz" "$INPUT_SOURCE"
mv "$tmp_dir/$INPUT_NAME.tgz" .

if [ "$INPUT_PASSWORD" == "" ]; then
  remote="$INPUT_USERNAME@$INPUT_HOST"
else
  remote="$INPUT_USERNAME:$INPUT_PASSWORD@$INPUT_HOST"
fi

extra_params=()

if [ "$INPUT_PRIVATE_KEY" != "" ]; then
  printf '%s' "$INPUT_PRIVATE_KEY" > "$HOME/.ssh/$INPUT_NAME.pem"
  chmod 600 "$HOME/.ssh/$INPUT_NAME.pem"
  extra_params=("-i" "$HOME/.ssh/$INPUT_NAME.pem")
fi

scp -P "$INPUT_PORT" "${extra_params[@]}" "$INPUT_NAME.tgz" "$remote:$INPUT_NAME.tgz"
rm -rf "$tmp_dir/$INPUT_NAME.tgz" .
ssh -p "$INPUT_PORT" "${extra_params[@]}" "$remote" 'bash -s' <<< "$REMOTE_CODE"
