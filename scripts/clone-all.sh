#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$root/repos"
mkdir -p "$target"

clone() {
  local name="$1" url="$2"
  if [ -d "$target/$name" ]; then
    echo "skip  $name (already exists)"
  else
    echo "clone $name"
    git clone --depth 1 "$url" "$target/$name"
  fi
}

clone Ni-Agent  https://github.com/YossefKhalil/Ni-Agent.git
clone Ni-Zep    https://github.com/YossefKhalil/Ni-Zep.git
clone Ni-Strata https://github.com/YossefKhalil/Ni-Strata.git

echo "done. repos in $target"