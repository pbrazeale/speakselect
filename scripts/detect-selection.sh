#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage:
  detect-selection.sh [--debug]

Outputs the current primary selection, or the clipboard if the primary
selection is empty or unsupported.
EOF
}

log_debug() {
    if [ "${DEBUG_MODE:-0}" -eq 1 ]; then
        printf '[detect-selection] %s\n' "$*" >&2
    fi
}

die() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

have_command() {
    command -v "$1" >/dev/null 2>&1
}

is_wayland() {
    [ "${XDG_SESSION_TYPE:-}" = "wayland" ] || [ -n "${WAYLAND_DISPLAY:-}" ]
}

is_x11() {
    [ "${XDG_SESSION_TYPE:-}" = "x11" ] || [ -n "${DISPLAY:-}" ]
}

capture_wayland_selection() {
    local selection_text=""

    if ! have_command wl-paste; then
        return 1
    fi

    selection_text="$(wl-paste --no-newline --primary 2>/dev/null || true)"
    if [ -n "${selection_text//[$'\t\r\n ']/}" ]; then
        log_debug "Using Wayland primary selection."
        printf '%s' "$selection_text"
        return 0
    fi

    selection_text="$(wl-paste --no-newline 2>/dev/null || true)"
    if [ -n "${selection_text//[$'\t\r\n ']/}" ]; then
        log_debug "Wayland primary selection was empty; falling back to clipboard."
        printf '%s' "$selection_text"
        return 0
    fi

    return 1
}

capture_x11_selection() {
    local selection_text=""

    if ! have_command xclip; then
        return 1
    fi

    selection_text="$(xclip -o -selection primary 2>/dev/null || true)"
    if [ -n "${selection_text//[$'\t\r\n ']/}" ]; then
        log_debug "Using X11 primary selection."
        printf '%s' "$selection_text"
        return 0
    fi

    selection_text="$(xclip -o -selection clipboard 2>/dev/null || true)"
    if [ -n "${selection_text//[$'\t\r\n ']/}" ]; then
        log_debug "X11 primary selection was empty; falling back to clipboard."
        printf '%s' "$selection_text"
        return 0
    fi

    return 1
}

main() {
    local selection_text=""
    DEBUG_MODE=0

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --debug)
                DEBUG_MODE=1
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

    if is_wayland; then
        selection_text="$(capture_wayland_selection || true)"
    fi

    if [ -z "${selection_text//[$'\t\r\n ']/}" ] && is_x11; then
        selection_text="$(capture_x11_selection || true)"
    fi

    if [ -z "${selection_text//[$'\t\r\n ']/}" ]; then
        if have_command wl-paste; then
            selection_text="$(capture_wayland_selection || true)"
        fi
    fi

    if [ -z "${selection_text//[$'\t\r\n ']/}" ]; then
        if have_command xclip; then
            selection_text="$(capture_x11_selection || true)"
        fi
    fi

    if [ -z "${selection_text//[$'\t\r\n ']/}" ]; then
        if ! have_command wl-paste && ! have_command xclip; then
            die "Neither wl-paste nor xclip is installed. Install wl-clipboard or xclip."
        fi

        die "No selected text was found. Highlight text first, or copy text to the clipboard."
    fi

    printf '%s' "$selection_text"
}

main "$@"
