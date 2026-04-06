#!/usr/bin/env bash
set -euo pipefail

INSTALL_BIN_DIR="${HOME}/.local/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/piper-speak"
CONFIG_FILE="${CONFIG_DIR}/config.env"
PIPER_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/piper"
REMOVE_CONFIG=0
REMOVE_VOICE=0
REMOVE_ALL_VOICES=0
ASSUME_YES=0
VOICE=""

usage() {
    cat <<'EOF'
Usage:
  ./uninstall.sh [options]

Options:
  --remove-config   Remove ~/.config/piper-speak/config.env
  --remove-voice    Remove the configured voice files
  --voice NAME      Remove a specific voice when used with --remove-voice
  --all-voices      Remove every *.onnx and *.onnx.json file from the Piper data dir
  --yes             Skip confirmation prompts
  -h, --help        Show this help text
EOF
}

log() {
    printf '%s\n' "$*"
}

confirm() {
    local prompt="$1"
    local reply=""

    if [ "$ASSUME_YES" -eq 1 ]; then
        return 0
    fi

    printf '%s [y/N] ' "$prompt" >&2
    read -r reply
    case "$reply" in
        y|Y|yes|YES)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

configured_voice() {
    if [ -f "$CONFIG_FILE" ]; then
        # shellcheck disable=SC1090
        source "$CONFIG_FILE"
        printf '%s\n' "${PIPER_VOICE:-en_GB-southern_english_female-low}"
        return 0
    fi

    printf '%s\n' "en_GB-southern_english_female-low"
}

remove_file_if_present() {
    local file_path="$1"

    if [ -e "$file_path" ]; then
        rm -f "$file_path"
        log "Removed ${file_path}."
    fi
}

main() {
    local selected_voice=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --remove-config)
                REMOVE_CONFIG=1
                shift
                ;;
            --remove-voice)
                REMOVE_VOICE=1
                shift
                ;;
            --voice)
                [ "$#" -ge 2 ] || {
                    printf 'Error: --voice requires a value.\n' >&2
                    exit 1
                }
                VOICE="$2"
                shift 2
                ;;
            --all-voices)
                REMOVE_ALL_VOICES=1
                shift
                ;;
            --yes)
                ASSUME_YES=1
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                printf 'Error: unknown option: %s\n' "$1" >&2
                exit 1
                ;;
        esac
    done

    remove_file_if_present "${INSTALL_BIN_DIR}/speak"
    remove_file_if_present "${INSTALL_BIN_DIR}/speak-selection"
    remove_file_if_present "${INSTALL_BIN_DIR}/speak-selection-debug"
    remove_file_if_present "${INSTALL_BIN_DIR}/detect-selection.sh"
    remove_file_if_present "${INSTALL_BIN_DIR}/test-voice.sh"
    remove_file_if_present "${INSTALL_BIN_DIR}/print-shortcut-instructions.sh"

    if [ "$REMOVE_CONFIG" -eq 1 ]; then
        if confirm "Remove ${CONFIG_FILE}?"; then
            remove_file_if_present "$CONFIG_FILE"
        fi
    else
        log "Keeping ${CONFIG_FILE}."
    fi

    if [ "$REMOVE_ALL_VOICES" -eq 1 ]; then
        if confirm "Remove every downloaded Piper voice from ${PIPER_DATA_DIR}?"; then
            if [ -d "$PIPER_DATA_DIR" ]; then
                find "$PIPER_DATA_DIR" -maxdepth 1 \( -name '*.onnx' -o -name '*.onnx.json' \) -type f -delete
                log "Removed voice files from ${PIPER_DATA_DIR}."
            else
                log "No Piper data directory found at ${PIPER_DATA_DIR}."
            fi
        fi
        exit 0
    fi

    if [ "$REMOVE_VOICE" -eq 1 ]; then
        selected_voice="${VOICE:-$(configured_voice)}"
        if confirm "Remove voice ${selected_voice} from ${PIPER_DATA_DIR}?"; then
            remove_file_if_present "${PIPER_DATA_DIR}/${selected_voice}.onnx"
            remove_file_if_present "${PIPER_DATA_DIR}/${selected_voice}.onnx.json"
        fi
    else
        log "Keeping downloaded voice files in ${PIPER_DATA_DIR}."
    fi
}

main "$@"
