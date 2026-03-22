#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SHORTCUT_COMMAND="${SCRIPT_DIR}/speak-selection"

if [ ! -x "$SHORTCUT_COMMAND" ] && [ -x "${SCRIPT_DIR}/../bin/speak-selection" ]; then
    SHORTCUT_COMMAND="$(cd -- "${SCRIPT_DIR}/../bin" && pwd)/speak-selection"
fi

if ! [ -x "$SHORTCUT_COMMAND" ] && command -v speak-selection >/dev/null 2>&1; then
    SHORTCUT_COMMAND="$(command -v speak-selection)"
fi

cat <<EOF
Recommended GNOME custom shortcut:

  Name: Speak Selection
  Command: ${SHORTCUT_COMMAND}
  Shortcut: Ctrl+Alt+Space

Notes:
  - Wayland relies on wl-paste and the active app exposing the selection.
  - X11 relies on xclip and can read the primary selection directly.
  - Run 'speak-selection --debug' from a terminal if the shortcut is silent.
EOF
