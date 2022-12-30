#!/bin/bash
set -e

source .env

restic -r $DS720_REPO_DIR \
  restore latest \
  --include="/Users/drio/dev/github.com/TuftsUniversity/google-camps-go" \
  --target=/tmp/google-camps-go \
  "--password-file=./pass.txt"
