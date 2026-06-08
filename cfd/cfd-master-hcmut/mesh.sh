#!/usr/bin/env bash
set -euo pipefail

# Build OpenFOAM mesh from generated manifold STL patches.
case_dir="$(cd "$(dirname "$0")" && pwd)"
cd "$case_dir"

src_stl="${1:-geometry/manifold.stl}"
tri_dir="constant/triSurface"
dst_stl="$tri_dir/manifold.stl"

if [[ ! -f "$src_stl" ]]; then
    echo "Source STL not found: $src_stl" >&2
    exit 1
fi

mkdir -p "$tri_dir"
cp "$src_stl" "$dst_stl"

echo "[mesh] Using STL: $dst_stl"

echo "[mesh] blockMesh"
blockMesh

echo "[mesh] surfaceFeatureExtract"
surfaceFeatureExtract

echo "[mesh] snappyHexMesh -overwrite"
snappyHexMesh -overwrite

echo "[mesh] checkMesh -meshQuality"
checkMesh -meshQuality

echo "[mesh] Done"
