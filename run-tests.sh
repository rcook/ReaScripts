#!/usr/bin/env bash
set -u

this_dir="$(cd "$(dirname "$0")" && pwd)"
cd "$this_dir"

shopt -s nullglob
files=(tests/test_*.lua)
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
  echo "No test files matching tests/test_*.lua"
  exit 0
fi

failed=0
for file in "${files[@]}"; do
  echo "=== $file ==="
  if ! lua "$file" "$@"; then
    failed=$((failed + 1))
  fi
  echo
done

echo "${#files[@]} file(s), $failed failed"
[ "$failed" -eq 0 ]
