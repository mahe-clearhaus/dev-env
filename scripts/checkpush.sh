#!/bin/bash

# Checks if your image has been pushed to ecr using $HEAD and your current project

REPO=$(basename "$(git rev-parse --show-toplevel)")
SHA=$(git rev-parse HEAD)

TAGS=$(aws ecr list-images --repository-name "$REPO" --query 'imageIds[].imageTag' --output text)
IMAGE=$(echo "$TAGS" | tr '\t' '\n' | grep -E "(^|-)${SHA}$" | head -n1) # ai 

if [ -z "$IMAGE" ]; then
  echo
  echo -e "\033[33m$REPO\033[0m contains"
  echo
  echo "$TAGS" | sed $'s/\t/\\n/g'
  echo
  echo -e "❌ \033[33m$REPO\033[0m ecr does not have $SHA"
  exit 1
else
  echo
  echo -e "✅ \033[33m$REPO\033[0m contains $IMAGE"
fi
