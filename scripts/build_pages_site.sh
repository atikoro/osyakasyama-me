#!/bin/sh

set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
destination=${1:-"$root/_site"}

rm -rf "$destination"
mkdir -p "$destination/episodes"

cp "$root/podcast/index.html" "$destination/index.html"
cp "$root/podcast/feed.xml" "$destination/feed.xml"
cp "$root/podcast/cover.jpg" "$destination/cover.jpg"
cp "$root/episodes/001-state-of-mind/audio/episode-001.m4a" \
  "$destination/episodes/episode-001.m4a"
touch "$destination/.nojekyll"

echo "Built: $destination"
