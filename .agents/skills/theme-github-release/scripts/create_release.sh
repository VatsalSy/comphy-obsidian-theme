#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  create_release.sh <version> [options]

Options:
  --notes-file <path>      Use custom release notes file
  --title <text>           Override release title
  --target <branch>        Override target branch for GitHub release
  --prerelease             Mark release as prerelease
  --skip-lint              Skip npm lint step
  --dry-run                Show actions without changing anything
  --skip-remote-checks     Skip gh auth and remote existence checks (for local dry-run)
  -h, --help               Show this help
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

run_cmd() {
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '[dry-run] '
    printf '%q ' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  usage
  exit 1
fi
shift || true

NOTES_FILE=""
TITLE=""
TARGET=""
PRERELEASE="0"
SKIP_LINT="0"
DRY_RUN="0"
SKIP_REMOTE_CHECKS="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --notes-file)
      [[ $# -ge 2 ]] || die "--notes-file requires a path"
      NOTES_FILE="$2"
      shift 2
      ;;
    --title)
      [[ $# -ge 2 ]] || die "--title requires text"
      TITLE="$2"
      shift 2
      ;;
    --target)
      [[ $# -ge 2 ]] || die "--target requires a branch name"
      TARGET="$2"
      shift 2
      ;;
    --prerelease)
      PRERELEASE="1"
      shift
      ;;
    --skip-lint)
      SKIP_LINT="1"
      shift
      ;;
    --dry-run)
      DRY_RUN="1"
      shift
      ;;
    --skip-remote-checks)
      SKIP_REMOTE_CHECKS="1"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
done

VERSION="${VERSION#v}"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z]+)*$ ]] || die "Version must look like 1.2.3 (or 1.2.3-rc1)"

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "$ROOT_DIR" ]] || die "Run this inside the git repository"
cd "$ROOT_DIR"

[[ -f manifest.json ]] || die "manifest.json not found"
[[ -f package.json ]] || die "package.json not found"
[[ -f versions.json ]] || die "versions.json not found"
[[ -f scripts/build-theme.sh ]] || die "scripts/build-theme.sh not found"

command -v git >/dev/null 2>&1 || die "git is required"
command -v node >/dev/null 2>&1 || die "node is required"
command -v npm >/dev/null 2>&1 || die "npm is required"

if [[ "$DRY_RUN" != "1" ]]; then
  git diff --quiet || die "Working tree has unstaged changes"
  git diff --cached --quiet || die "Working tree has staged changes"
fi

if git rev-parse -q --verify "refs/tags/$VERSION" >/dev/null 2>&1; then
  die "Tag already exists locally: $VERSION"
fi

if [[ "$SKIP_REMOTE_CHECKS" != "1" ]]; then
  command -v gh >/dev/null 2>&1 || die "gh is required"
  gh auth status >/dev/null 2>&1 || die "gh is not authenticated"

  if git ls-remote --tags origin "refs/tags/$VERSION" | grep -q "refs/tags/$VERSION"; then
    die "Tag already exists on origin: $VERSION"
  fi

  if gh release view "$VERSION" >/dev/null 2>&1; then
    die "GitHub release already exists: $VERSION"
  fi
fi

if [[ -n "$NOTES_FILE" && ! -f "$NOTES_FILE" ]]; then
  die "Notes file not found: $NOTES_FILE"
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [[ -z "$TARGET" ]]; then
  TARGET="$CURRENT_BRANCH"
fi

MIN_APP_VERSION="$(node -e 'const fs=require("fs");const m=JSON.parse(fs.readFileSync("manifest.json","utf8"));process.stdout.write(m.minAppVersion||"1.0.0");')"

update_versions() {
  node - "$VERSION" "$MIN_APP_VERSION" <<'NODE'
const fs = require("fs");

const version = process.argv[2];
const minAppVersion = process.argv[3];

const manifestPath = "manifest.json";
const packagePath = "package.json";
const versionsPath = "versions.json";

const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
manifest.version = version;
fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + "\n");

const pkg = JSON.parse(fs.readFileSync(packagePath, "utf8"));
pkg.version = version;
fs.writeFileSync(packagePath, JSON.stringify(pkg, null, 2) + "\n");

const versions = JSON.parse(fs.readFileSync(versionsPath, "utf8"));
versions[version] = minAppVersion;
fs.writeFileSync(versionsPath, JSON.stringify(versions, null, 2) + "\n");
NODE
}

if [[ "$DRY_RUN" == "1" ]]; then
  printf '[dry-run] Would set version=%s in manifest.json/package.json and versions.json[%s]=%s\n' "$VERSION" "$VERSION" "$MIN_APP_VERSION"
else
  update_versions
fi

run_cmd bash scripts/build-theme.sh
if [[ "$SKIP_LINT" != "1" ]]; then
  run_cmd npm run lint:css
fi

run_cmd git add manifest.json package.json versions.json theme.css
run_cmd git commit -m "Release $VERSION"
# Use an explicit message so non-interactive runs never block on TAG_EDITMSG.
# Keep `-s` so release tags are always signed even if local config changes.
run_cmd git tag -s -m "Release $VERSION" "$VERSION"
run_cmd git push origin HEAD
run_cmd git push origin "$VERSION"

RELEASE_TITLE="$TITLE"
if [[ -z "$RELEASE_TITLE" ]]; then
  RELEASE_TITLE="comphy-obsidian-theme $VERSION"
fi

release_cmd=(gh release create "$VERSION" --title "$RELEASE_TITLE" --target "$TARGET")
if [[ "$PRERELEASE" == "1" ]]; then
  release_cmd+=(--prerelease)
fi
if [[ -n "$NOTES_FILE" ]]; then
  release_cmd+=(--notes-file "$NOTES_FILE")
else
  release_cmd+=(--generate-notes)
fi

if [[ "$SKIP_REMOTE_CHECKS" == "1" ]]; then
  printf 'Skipping GitHub release creation because --skip-remote-checks was set.\n'
else
  run_cmd "${release_cmd[@]}"
fi

printf 'Release workflow complete for version %s\n' "$VERSION"
