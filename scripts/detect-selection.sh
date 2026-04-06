#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage:
  detect-selection.sh [--debug] [--selection-mode MODE]

Selection modes:
  --prefer-primary
  --prefer-clipboard
  --primary-only
  --clipboard-only

Options:
  --selection-mode MODE  One of prefer-primary, prefer-clipboard,
                         primary-only, clipboard-only
  --retry-count COUNT    Number of primary-selection attempts
  --retry-delay-ms MS    Delay between primary retries in milliseconds
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

trimmed_text() {
    local raw_text="$1"
    printf '%s' "${raw_text//[$'\t\r\n ']/}"
}

has_text() {
    [ -n "$(trimmed_text "$1")" ]
}

is_wayland() {
    [ "${XDG_SESSION_TYPE:-}" = "wayland" ] || [ -n "${WAYLAND_DISPLAY:-}" ]
}

is_x11() {
    [ "${XDG_SESSION_TYPE:-}" = "x11" ] || [ -n "${DISPLAY:-}" ]
}

validate_mode() {
    case "$1" in
        prefer-primary|prefer-clipboard|primary-only|clipboard-only)
            return 0
            ;;
        *)
            die "Unknown selection mode: $1"
            ;;
    esac
}

validate_non_negative_integer() {
    case "$1" in
        ''|*[!0-9]*)
            return 1
            ;;
        *)
            return 0
            ;;
    esac
}

sleep_ms() {
    local milliseconds="$1"

    if [ "$milliseconds" -le 0 ]; then
        return 0
    fi

    sleep "$(awk -v milliseconds="$milliseconds" 'BEGIN { printf "%.3f", milliseconds / 1000 }')"
}

capture_wayland_source() {
    local source_name="$1"
    local selection_text=""
    local -a command_args=(--no-newline)

    if ! have_command wl-paste; then
        return 1
    fi

    if [ "$source_name" = "primary" ]; then
        command_args+=(--primary)
    fi

    selection_text="$(wl-paste "${command_args[@]}" 2>/dev/null || true)"
    if has_text "$selection_text"; then
        CAPTURED_TEXT="$selection_text"
        DETECTED_SOURCE="wayland-${source_name}"
        return 0
    fi

    return 1
}

capture_x11_source() {
    local source_name="$1"
    local selection_text=""

    if ! have_command xclip; then
        return 1
    fi

    selection_text="$(xclip -o -selection "$source_name" 2>/dev/null || true)"
    if has_text "$selection_text"; then
        CAPTURED_TEXT="$selection_text"
        DETECTED_SOURCE="x11-${source_name}"
        return 0
    fi

    return 1
}

capture_source_once() {
    local source_name="$1"

    if is_wayland; then
        capture_wayland_source "$source_name" && return 0
    fi

    if is_x11; then
        capture_x11_source "$source_name" && return 0
    fi

    if ! is_wayland && have_command wl-paste; then
        capture_wayland_source "$source_name" && return 0
    fi

    if ! is_x11 && have_command xclip; then
        capture_x11_source "$source_name" && return 0
    fi

    return 1
}

capture_with_retries() {
    local source_name="$1"
    local retry_count="$2"
    local retry_delay_ms="$3"
    local attempt=1
    local effective_attempts=1

    if [ "$source_name" = "primary" ] && [ "$retry_count" -gt 0 ]; then
        effective_attempts="$retry_count"
    fi

    while [ "$attempt" -le "$effective_attempts" ]; do
        CAPTURED_TEXT=""
        DETECTED_SOURCE=""

        if capture_source_once "$source_name"; then
            return 0
        fi

        if [ "$attempt" -lt "$effective_attempts" ]; then
            sleep_ms "$retry_delay_ms"
        fi

        attempt=$((attempt + 1))
    done

    return 1
}

emit_missing_text_error() {
    local selection_mode="$1"

    case "$selection_mode" in
        primary-only)
            die "No highlighted text was found. Highlight text first, then try again."
            ;;
        clipboard-only)
            die "No clipboard text was found. Copy text to the clipboard first, then try again."
            ;;
        prefer-primary)
            die "No text was found in the highlighted selection or clipboard."
            ;;
        prefer-clipboard)
            die "No text was found in the clipboard or highlighted selection."
            ;;
    esac
}

main() {
    local selection_text=""
    local selection_mode="${SELECTION_SOURCE_MODE:-primary-only}"
    local retry_count="${SELECTION_RETRY_COUNT:-3}"
    local retry_delay_ms="${SELECTION_RETRY_DELAY_MS:-50}"
    local source_name=""

    DEBUG_MODE=0
    CAPTURED_TEXT=""
    DETECTED_SOURCE=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --debug)
                DEBUG_MODE=1
                shift
                ;;
            --selection-mode)
                [ "$#" -ge 2 ] || die "--selection-mode requires a value."
                selection_mode="$2"
                shift 2
                ;;
            --prefer-primary)
                selection_mode="prefer-primary"
                shift
                ;;
            --prefer-clipboard)
                selection_mode="prefer-clipboard"
                shift
                ;;
            --primary-only)
                selection_mode="primary-only"
                shift
                ;;
            --clipboard-only)
                selection_mode="clipboard-only"
                shift
                ;;
            --retry-count)
                [ "$#" -ge 2 ] || die "--retry-count requires a value."
                retry_count="$2"
                shift 2
                ;;
            --retry-delay-ms)
                [ "$#" -ge 2 ] || die "--retry-delay-ms requires a value."
                retry_delay_ms="$2"
                shift 2
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

    validate_mode "$selection_mode"
    validate_non_negative_integer "$retry_count" || die "--retry-count must be a non-negative integer."
    validate_non_negative_integer "$retry_delay_ms" || die "--retry-delay-ms must be a non-negative integer."

    if ! have_command wl-paste && ! have_command xclip; then
        die "Neither wl-paste nor xclip is installed. Install wl-clipboard or xclip."
    fi

    case "$selection_mode" in
        prefer-primary)
            for source_name in primary clipboard; do
                if capture_with_retries "$source_name" "$retry_count" "$retry_delay_ms"; then
                    selection_text="$CAPTURED_TEXT"
                    break
                fi
            done
            ;;
        prefer-clipboard)
            for source_name in clipboard primary; do
                if capture_with_retries "$source_name" "$retry_count" "$retry_delay_ms"; then
                    selection_text="$CAPTURED_TEXT"
                    break
                fi
            done
            ;;
        primary-only)
            if capture_with_retries primary "$retry_count" "$retry_delay_ms"; then
                selection_text="$CAPTURED_TEXT"
            fi
            ;;
        clipboard-only)
            if capture_with_retries clipboard "$retry_count" "$retry_delay_ms"; then
                selection_text="$CAPTURED_TEXT"
            fi
            ;;
    esac

    if ! has_text "$selection_text"; then
        emit_missing_text_error "$selection_mode"
    fi

    log_debug "source=${DETECTED_SOURCE}"
    printf '%s' "$selection_text"
}

main "$@"
