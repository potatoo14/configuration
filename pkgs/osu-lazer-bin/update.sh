#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash cacert curl jq nix unzip common-updater-scripts
set -euo pipefail
new_tag_name="$(curl -s "https://api.github.com/repos/ppy/osu/releases/latest" | jq -r '.name')"
new_version="${new_tag_name%-lazer}"
old_version="$(nix eval --raw -f . osu-lazer-bin.version)"

if [[ "$new_version" == "$old_version" ]]; then
	echo "Already up to date."
	exit 0
fi

echo "Updating osu-lazer-bin from $old_version to $new_version..."

echo "Prefetching binary..."
prefetch_output=$(nix --extra-experimental-features nix-command store prefetch-file --json --hash-type sha256 "https://github.com/ppy/osu/releases/download/$new_tag_name/osu.AppImage")
hash=$(jq -r '.hash' <<<"$prefetch_output")
echo "hash = $hash"
update-source-version osu-lazer-bin "$new_version" "$hash" --file=package.nix
