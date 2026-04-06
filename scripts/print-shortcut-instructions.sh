#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
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

For manual debugging in your current terminal:

  Command: ${SHORTCUT_COMMAND} --debug

If you want SpeakSelect to open its own debug terminal window:

  Name: Speak Selection
  Command: $(dirname "${SHORTCUT_COMMAND}")/speak-selection-debug

Notes:
  - Bind plain 'speak-selection' for the everyday shortcut path.
  - The default selection mode is primary-only, so highlighted text is required.
  - Wayland relies on wl-paste and the active app exposing the selection.
  - X11 relies on xclip and can read the primary selection directly.
  - Run 'speak-selection --debug' from a terminal to see the exact source used.
EOF
