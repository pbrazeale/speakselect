#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
REPO_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
readonly REPO_DIR

SPEAK_BIN="${REPO_DIR}/bin/speak"

if command -v speak >/dev/null 2>&1; then
    SPEAK_BIN="$(command -v speak)"
fi

if [ ! -x "$SPEAK_BIN" ]; then
    printf 'Error: could not find an executable speak command.\n' >&2
    exit 1
fi

printf 'Running a short speech test with %s\n' "$SPEAK_BIN" >&2
exec "$SPEAK_BIN" "SpeakSelect is installed and working."
