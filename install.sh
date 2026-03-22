#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_DIR
readonly EXAMPLE_CONFIG="${REPO_DIR}/config/piper-speak.env.example"

INSTALL_BIN_DIR="${HOME}/.local/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/piper-speak"
CONFIG_FILE="${CONFIG_DIR}/config.env"
PIPER_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/piper"
VOICE="en_GB-southern_english_female-low"
SPEED="1.0"
PYTHON_BIN="python3"
FORCE=0
SKIP_DEPS=0

usage() {
    cat <<'EOF'
Usage:
  ./install.sh [options]

Options:
  --voice NAME     Default Piper voice to install
  --speed SCALE    Default PIPER_LENGTH_SCALE value
  --python PATH    Python interpreter to use for Piper
  --force          Overwrite an existing config.env
  --skip-deps      Skip system package and pip dependency installation
  -h, --help       Show this help text
EOF
}

log() {
    printf '%s\n' "$*"
}

warn() {
    printf 'Warning: %s\n' "$*" >&2
}

die() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

have_command() {
    command -v "$1" >/dev/null 2>&1
}

run_with_privilege() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
        return 0
    fi

    if have_command sudo; then
        sudo "$@"
        return 0
    fi

    die "Need root privileges to install system packages, but sudo is not available."
}

python_install_args() {
    local python_bin="$1"

    if "$python_bin" -c 'import sys; raise SystemExit(0 if (hasattr(sys, "base_prefix") and sys.prefix != sys.base_prefix) or getattr(sys, "real_prefix", "") else 1)' >/dev/null 2>&1; then
        return 1
    fi

    return 0
}

ensure_python_available() {
    have_command "$PYTHON_BIN" || die "Python interpreter '${PYTHON_BIN}' was not found."

    "$PYTHON_BIN" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 9) else 1)' \
        || die "Piper requires Python 3.9 or newer."

    "$PYTHON_BIN" -m pip --version >/dev/null 2>&1 \
        || die "pip is not available for ${PYTHON_BIN}. Install pip first."
}

missing_runtime_packages() {
    local missing=()

    have_command ffplay || missing+=("ffmpeg")
    have_command xclip || missing+=("xclip")
    have_command wl-paste || missing+=("wl-clipboard")

    printf '%s\n' "${missing[@]}"
}

install_system_packages() {
    local packages=()
    local missing_output=""

    missing_output="$(missing_runtime_packages)"
    if [ -z "$missing_output" ]; then
        log "System audio/selection dependencies are already present."
        return 0
    fi

    mapfile -t packages <<<"$missing_output"
    log "Missing system packages: ${packages[*]}"

    if have_command apt-get; then
        log "Installing missing packages with apt-get."
        run_with_privilege apt-get update
        run_with_privilege apt-get install -y "${packages[@]}"
        return 0
    fi

    if have_command dnf; then
        log "Installing missing packages with dnf."
        run_with_privilege dnf install -y "${packages[@]}"
        return 0
    fi

    if have_command pacman; then
        log "Installing missing packages with pacman."
        run_with_privilege pacman -Sy --noconfirm "${packages[@]}"
        return 0
    fi

    if have_command zypper; then
        log "Installing missing packages with zypper."
        run_with_privilege zypper install -y "${packages[@]}"
        return 0
    fi

    warn "Could not detect a supported package manager."
    warn "Install these packages manually: ${packages[*]}"
}

install_python_packages() {
    local install_args=()

    ensure_python_available

    if python_install_args "$PYTHON_BIN"; then
        install_args=(--user)
    fi

    log "Installing Piper Python packages with ${PYTHON_BIN}."
    "$PYTHON_BIN" -m pip install "${install_args[@]}" --upgrade piper-tts pathvalidate
}

install_voice() {
    local model_file="${PIPER_DATA_DIR}/${VOICE}.onnx"
    local model_config_file="${model_file}.json"

    mkdir -p "$PIPER_DATA_DIR"

    if [ -f "$model_file" ] && [ -f "$model_config_file" ]; then
        log "Voice ${VOICE} is already downloaded."
        return 0
    fi

    log "Downloading Piper voice ${VOICE} into ${PIPER_DATA_DIR}."
    "$PYTHON_BIN" -m piper.download_voices --data-dir "$PIPER_DATA_DIR" "$VOICE"
}

render_config() {
    mkdir -p "$CONFIG_DIR"

    if [ -f "$CONFIG_FILE" ] && [ "$FORCE" -ne 1 ]; then
        log "Keeping existing config at ${CONFIG_FILE}."
        return 0
    fi

    [ -f "$EXAMPLE_CONFIG" ] || die "Missing example config at ${EXAMPLE_CONFIG}."

    sed \
        -e "s|^PIPER_DATA_DIR=.*$|PIPER_DATA_DIR=\"${PIPER_DATA_DIR}\"|" \
        -e "s|^PIPER_VOICE=.*$|PIPER_VOICE=\"${VOICE}\"|" \
        -e "s|^PIPER_LENGTH_SCALE=.*$|PIPER_LENGTH_SCALE=\"${SPEED}\"|" \
        -e "s|^PIPER_PYTHON=.*$|PIPER_PYTHON=\"${PYTHON_BIN}\"|" \
        "$EXAMPLE_CONFIG" >"$CONFIG_FILE"

    log "Wrote config to ${CONFIG_FILE}."
}

install_scripts() {
    mkdir -p "$INSTALL_BIN_DIR"

    install -m 0755 "${REPO_DIR}/bin/speak" "${INSTALL_BIN_DIR}/speak"
    install -m 0755 "${REPO_DIR}/bin/speak-selection" "${INSTALL_BIN_DIR}/speak-selection"
    install -m 0755 "${REPO_DIR}/scripts/detect-selection.sh" "${INSTALL_BIN_DIR}/detect-selection.sh"
    install -m 0755 "${REPO_DIR}/scripts/test-voice.sh" "${INSTALL_BIN_DIR}/test-voice.sh"
    install -m 0755 "${REPO_DIR}/scripts/print-shortcut-instructions.sh" "${INSTALL_BIN_DIR}/print-shortcut-instructions.sh"

    log "Installed scripts into ${INSTALL_BIN_DIR}."
}

print_next_steps() {
    log ""
    log "Next steps:"
    if ! printf '%s' ":${PATH}:" | grep -Fq ":${INSTALL_BIN_DIR}:"; then
        log "  1. Add ${INSTALL_BIN_DIR} to your PATH."
    fi
    log "  2. Test the install with: speak \"hello\""
    log "  3. Optional: bind speak-selection to Ctrl+Alt+Space."
    log "  4. Shortcut help: print-shortcut-instructions.sh"
}

main() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --voice)
                [ "$#" -ge 2 ] || die "--voice requires a value."
                VOICE="$2"
                shift 2
                ;;
            --speed)
                [ "$#" -ge 2 ] || die "--speed requires a value."
                SPEED="$2"
                shift 2
                ;;
            --python)
                [ "$#" -ge 2 ] || die "--python requires a value."
                PYTHON_BIN="$2"
                shift 2
                ;;
            --force)
                FORCE=1
                shift
                ;;
            --skip-deps)
                SKIP_DEPS=1
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

    mkdir -p "$INSTALL_BIN_DIR" "$CONFIG_DIR" "$PIPER_DATA_DIR"

    if [ "$SKIP_DEPS" -eq 0 ]; then
        install_system_packages
        install_python_packages
    else
        ensure_python_available
        log "Skipping system package and pip dependency installation."
    fi

    install_voice
    install_scripts
    render_config
    print_next_steps
}

main "$@"
