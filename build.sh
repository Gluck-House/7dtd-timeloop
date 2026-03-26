#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dotnet_cmd="${DOTNET:-dotnet}"
build_output_dir="${BUILD_OUTPUT_DIR:-$repo_root/TimeLoop/build/TimeLoop}"
zip_root_dir="${ZIP_ROOT_DIR:-timeloop}"
zip_path="${ZIP_PATH:-$repo_root/TimeLoop/build/TimeLoop.zip}"

if ! command -v "$dotnet_cmd" >/dev/null 2>&1; then
    if [ -x "$HOME/.local/share/dotnet/dotnet" ]; then
        dotnet_cmd="$HOME/.local/share/dotnet/dotnet"
    else
        echo "dotnet SDK not found. Install .NET SDK 8+ or set DOTNET=/full/path/to/dotnet." >&2
        exit 1
    fi
fi

"$dotnet_cmd" build "$repo_root/TimeLoop/TimeLoop.sln" "$@"

if [ ! -d "$build_output_dir" ]; then
    echo "Build output directory not found: $build_output_dir" >&2
    exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
    echo "zip command not found." >&2
    exit 1
fi

staging_dir="$(mktemp -d)"
trap 'rm -rf "$staging_dir"' EXIT

mkdir -p "$(dirname "$zip_path")" "$staging_dir/$zip_root_dir"
cp -R "$build_output_dir"/. "$staging_dir/$zip_root_dir/"

rm -f "$zip_path"
(
    cd "$staging_dir"
    zip -rq "$zip_path" "$zip_root_dir"
)

echo "Created archive: $zip_path"
