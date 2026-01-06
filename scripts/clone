#!/bin/bash

# Usage: ./clone.sh <repo-name>

if [ -z "$1" ]; then
  echo "Usage: $0 <repo-name>"
  exit 1
fi

REPO_NAME="$1"
GIT_URL="git@github.com:clearhaus/$REPO_NAME.git"

echo "Cloning $REPO_NAME from Clearhaus..."
git clone "$GIT_URL"


