#!/usr/bin/env bash

# script to check if the files overwritten in `insight` docker image
# has been changed in the upstream repo.

set -euo pipefail

current_sha1="${CIRCLE_SHA1:-HEAD}"
upstream_branch="upstream/master"

# get overwritten files
files=($(grep '^ADD ' Dockerfile.insight | awk '{print $2}'))
echo "files overwritten in Dockerfile.insight:"
for file in "${files[@]}"; do echo "  - $file"; done

# add & fetch upstream remote
git remote add -f upstream git@github.com:jupyter/nbviewer.git 2>/dev/null || true

# find branch point
branch_point_sha1=`git merge-base $current_sha1 $upstream_branch`
echo "branch point: $branch_point_sha1"

# diff files
exit_code=0
for file in "${files[@]}"; do
  if [ -n "$(git diff $branch_point_sha1..$upstream_branch "$file")" ]; then
    echo "Found changes in file $file"
    exit_code=1
  fi
done

if [ $exit_code -eq 0 ]; then
  echo "SUCCESS - no changes to overwritten files"
fi

exit $exit_code
