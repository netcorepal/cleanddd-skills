#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_DIR="${REPO_ROOT}/skills"
TARGET_DIR="${SKILL_TARGET_DIR:-${HOME}/.claude/skills}"

usage() {
  echo "Usage: $(basename "$0") [--target DIR]" >&2
  echo "Installs all skills from ${SOURCE_DIR} into the user-level skill directory." >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      [[ $# -ge 2 ]] || { echo "--target requires a path" >&2; exit 1; }
      TARGET_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

mkdir -p "${TARGET_DIR}"

shopt -s nullglob
for skill_dir in "${SOURCE_DIR}"/*; do
  [[ -d "${skill_dir}" ]] || continue
  skill_name="$(basename "${skill_dir}")"
  dest_dir="${TARGET_DIR}/${skill_name}"
  rm -rf "${dest_dir}"
  cp -R "${skill_dir}" "${dest_dir}"
done
shopt -u nullglob

echo "Installed skills to ${TARGET_DIR}"