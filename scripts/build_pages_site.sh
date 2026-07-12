#!/bin/sh

set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
destination=${1:-"$root/_site"}

rm -rf "$destination"
mkdir -p "$destination/episodes"

cp "$root/podcast/index.html" "$destination/index.html"
cp "$root/podcast/feed.xml" "$destination/feed.xml"
cp "$root/podcast/cover.jpg" "$destination/cover.jpg"
found_audio=false
publishable=$(ruby -ryaml -e '
  Dir[File.join(ARGV.fetch(0), "episodes", "*", "metadata.yaml")].sort.each do |path|
    metadata = Psych.safe_load(File.read(path), aliases: false)
    next unless ["audio_approved", "published"].include?(metadata["status"])
    puts File.expand_path(metadata.dig("audio", "file"), File.dirname(path))
  end
' "$root")

for audio in $publishable; do
  cp "$audio" "$destination/episodes/$(basename "$audio")"
  found_audio=true
done

if [ "$found_audio" = false ]; then
  echo "No publishable M4A files found." >&2
  exit 1
fi
touch "$destination/.nojekyll"

echo "Built: $destination"
