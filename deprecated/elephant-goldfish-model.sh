#!/usr/bin/env bash
# egm-install.sh — clone/pull repo, symlink resources/ and agents/
set -euo pipefail
REPO=https://github.com/google/elephant-goldfish-model
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
DEST="$SCRIPT_DIR/elephant-goldfish-model"

if [ ! -d "$DEST/.git" ]; then
  git clone --depth 1 "$REPO" "$DEST"
else
  git -C "$DEST" pull --ff-only
fi

ln -sfn "$DEST/resources" "$SCRIPT_DIR/resources"
ln -sfn "$DEST/agents"    "$SCRIPT_DIR/agents"

bunx skills install "$DEST" --global --skill '*' --yes
