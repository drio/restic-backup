#!/bin/bash
set -e

source .env

for r in $DS720_REPO_DIR $WD_REPO_DIR;do
  echo $r
  restic -r $r cache --cleanup
done

echo "b2"
export $B2_VARS
restic -r $B2_URL cache --cleanup
