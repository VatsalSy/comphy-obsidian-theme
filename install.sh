#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash install.sh /path/to/obsidian/vault

Description:
  Installs this theme into:
    <vault>/.obsidian/themes/<Theme Name from manifest.json>

  Existing installed copies of the same theme (matched by manifest "name")
  are removed first.
EOF
}

get_json_name() {
  local manifest_path="$1"
  sed -nE 's/^[[:space:]]*"name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' "$manifest_path" | head -n 1
}

resolve_path() {
  local raw="$1"
  if [[ "$raw" == "~" ]]; then
    raw="$HOME"
  elif [[ "$raw" == "~/"* ]]; then
    raw="$HOME/${raw:2}"
  fi
  (cd "$raw" && pwd -P)
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SOURCE_MANIFEST="$SCRIPT_DIR/manifest.json"
SOURCE_THEME_CSS="$SCRIPT_DIR/theme.css"
SOURCE_VERSIONS="$SCRIPT_DIR/versions.json"
SOURCE_THEME_DIR="$SCRIPT_DIR/src/theme"
BUILD_SCRIPT="$SCRIPT_DIR/scripts/build-theme.sh"

if [[ -d "$SOURCE_THEME_DIR" && -f "$BUILD_SCRIPT" ]]; then
  can_rebuild=true
  if [[ -f "$SOURCE_THEME_CSS" ]]; then
    [[ -w "$SOURCE_THEME_CSS" ]] || can_rebuild=false
  else
    [[ -w "$SCRIPT_DIR" ]] || can_rebuild=false
  fi

  echo "Detected modular theme sources at $SOURCE_THEME_DIR"
  if [[ "$can_rebuild" == "true" ]]; then
    echo "Rebuilding theme.css before install..."
    bash "$BUILD_SCRIPT"
  else
    echo "Source tree is read-only; skipping rebuild and using existing theme.css."
  fi
fi

if [[ ! -f "$SOURCE_MANIFEST" ]]; then
  echo "Error: missing source manifest at $SOURCE_MANIFEST" >&2
  exit 1
fi
if [[ ! -f "$SOURCE_THEME_CSS" ]]; then
  echo "Error: missing source theme at $SOURCE_THEME_CSS" >&2
  exit 1
fi

THEME_NAME="$(get_json_name "$SOURCE_MANIFEST")"
if [[ -z "$THEME_NAME" ]]; then
  echo "Error: could not read theme name from $SOURCE_MANIFEST" >&2
  exit 1
fi

VAULT_ARG="$1"
if ! VAULT_PATH="$(resolve_path "$VAULT_ARG" 2>/dev/null)"; then
  echo "Error: vault path does not exist or is not a directory: $VAULT_ARG" >&2
  exit 1
fi

THEMES_DIR="$VAULT_PATH/.obsidian/themes"
mkdir -p "$THEMES_DIR"

purge_count=0

# Remove any existing theme directories whose manifest name matches this theme.
while IFS= read -r -d '' installed_manifest; do
  installed_dir="$(dirname "$installed_manifest")"
  installed_name="$(get_json_name "$installed_manifest" || true)"
  if [[ "$installed_name" == "$THEME_NAME" ]]; then
    rm -rf "$installed_dir"
    purge_count=$((purge_count + 1))
  fi
done < <(find "$THEMES_DIR" -mindepth 2 -maxdepth 2 -type f -name manifest.json -print0 2>/dev/null)

TARGET_DIR="$THEMES_DIR/$THEME_NAME"
if [[ -d "$TARGET_DIR" ]]; then
  rm -rf "$TARGET_DIR"
  purge_count=$((purge_count + 1))
fi

mkdir -p "$TARGET_DIR"
cp "$SOURCE_THEME_CSS" "$TARGET_DIR/theme.css"
cp "$SOURCE_MANIFEST" "$TARGET_DIR/manifest.json"
if [[ -f "$SOURCE_VERSIONS" ]]; then
  cp "$SOURCE_VERSIONS" "$TARGET_DIR/versions.json"
fi

echo "Installed theme: $THEME_NAME"
echo "Vault: $VAULT_PATH"
echo "Theme directory: $TARGET_DIR"
echo "Purged existing copies: $purge_count"
echo "Next: in Obsidian, go to Settings -> Appearance -> Themes and select \"$THEME_NAME\"."
