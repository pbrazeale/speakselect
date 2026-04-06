# SpeakSelect

<p align="center">
  <img src="./speakselect_logo.webp" alt="SpeakSelect logo" width="220">
</p>

SpeakSelect packages Piper into a small Linux-first speech workflow with:

- `speak "hello world"`
- `speak-selection`
- `piper-server`

The default runtime is now a local client/server model on the same machine:

- `piper-server` starts a Piper HTTP server on `127.0.0.1:5000` by default
- `speak` sends synthesis requests to that local server
- `speak-selection` captures highlighted text and forwards it through `speak`

No remote clients are involved in the intended setup. SpeakSelect does not need public ports, firewall changes, or another computer streaming audio back to this one.

The project still supports two runtime modes:

- `http`: a local Piper HTTP server with a thin `speak` client on loopback only
- `cli`: direct per-run Piper invocation as a compatibility fallback

The scripts remain readable Bash entrypoints that do not depend on shell functions in `~/.bashrc`.

## Features

- One-command install with `./install.sh`
- Standalone `speak` command for direct text or stdin in local HTTP mode or CLI fallback mode
- Standalone `speak-selection` command for highlighted text on Wayland or X11
- `piper-server` lifecycle helper for the local Piper HTTP server on `127.0.0.1:5000` by default
- Dedicated `speak-selection-debug` helper for visible terminal troubleshooting
- Config file at `~/.config/piper-speak/config.env`
- Default voice set to `en_GB-southern_english_female-low`
- WAV output plus `ffplay` playback for predictable local audio
- Helper commands for testing, voice listing, and keyboard shortcut setup

## How It Works

Normal local flow:

1. `piper-server start` launches Piper's HTTP server on `127.0.0.1:5000` unless you change the local config.
2. `speak "hello"` sends text to that local endpoint.
3. Piper returns WAV audio.
4. SpeakSelect plays the WAV locally with `ffplay`.

Selection flow:

1. You highlight text in an app.
2. `speak-selection` reads the primary selection.
3. The text is passed to `speak`.
4. `speak` sends it to the local Piper server and plays the result.

The default selection mode is `primary-only`, so SpeakSelect no longer silently falls back to stale clipboard text unless you explicitly opt into that behavior.

## Demo Usage

```bash
speak "hello world"
printf 'hello from stdin\n' | speak
speak --list-voices
speak --faster
speak --slower
speak --set-voice en_US-lessac-medium
piper-server start
speak --check-server
speak "hello world"
speak-selection --debug
speak-selection-debug
```

## Requirements

SpeakSelect is intentionally small, but the full system still depends on a few pieces:

- Linux
- Python 3.9+
- Internet access during first install to download Python packages and a Piper voice model
- `ffmpeg`, specifically `ffplay`, for playback
- `wl-clipboard` on Wayland or `xclip` on X11 for selection capture
- Local audio output that `ffplay` can use
- `sudo` if you want `install.sh` to install missing system packages for you

This repository installs Piper from PyPI with:

```bash
python3 -m pip install 'piper-tts[http]' pathvalidate
```

It then downloads a voice with Piper's documented downloader.

## Quick Install

```bash
git clone https://github.com/pbrazeale/speakselect.git
cd speakselect
chmod +x install.sh
./install.sh
```

Then test it:

```bash
piper-server start
speak --check-server
speak "hello"
```

If you already have a `~/.config/piper-speak/config.env`, rerunning `./install.sh` now migrates it by appending any missing settings and writing a backup to `config.env.bak`.

If `~/.local/bin` is not on your `PATH`, add it in your shell profile:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Manual Install

1. Install system packages:

```bash
# Debian/Ubuntu
sudo apt-get update
sudo apt-get install -y ffmpeg xclip wl-clipboard
```

2. Install Piper:

```bash
python3 -m pip install --user --upgrade 'piper-tts[http]' pathvalidate
```

3. Download the default voice:

```bash
python3 -m piper.download_voices --data-dir "$HOME/.local/share/piper" en_GB-southern_english_female-low
```

4. Copy the scripts:

```bash
mkdir -p "$HOME/.local/bin"
install -m 0755 bin/speak "$HOME/.local/bin/speak"
install -m 0755 bin/piper-server "$HOME/.local/bin/piper-server"
install -m 0755 bin/speak-selection "$HOME/.local/bin/speak-selection"
install -m 0755 bin/speak-selection-debug "$HOME/.local/bin/speak-selection-debug"
install -m 0755 scripts/detect-selection.sh "$HOME/.local/bin/detect-selection.sh"
install -m 0755 scripts/test-voice.sh "$HOME/.local/bin/test-voice.sh"
install -m 0755 scripts/print-shortcut-instructions.sh "$HOME/.local/bin/print-shortcut-instructions.sh"
```

5. Create your config:

```bash
mkdir -p "$HOME/.config/piper-speak"
cp config/piper-speak.env.example "$HOME/.config/piper-speak/config.env"
```

If you already have a config file, rerun `./install.sh` instead of replacing it manually so missing settings are appended safely.

## Configuration

SpeakSelect reads configuration from:

```bash
~/.config/piper-speak/config.env
```

Example:

```bash
PIPER_DATA_DIR="$HOME/.local/share/piper"
PIPER_VOICE="en_GB-southern_english_female-low"
PIPER_LENGTH_SCALE="1.0"
PIPER_PYTHON="python3"
PIPER_MODE="http"
PIPER_HTTP_HOST="127.0.0.1"
PIPER_HTTP_PORT="5000"
PIPER_HTTP_VOICE="en_GB-southern_english_female-low"
SELECTION_SOURCE_MODE="primary-only"
```

Useful commands:

- `speak --print-config`
- `speak --list-voices`
- `speak --faster`
- `speak --slower`
- `speak --set-voice en_US-lessac-medium`
- `speak --check-server`
- `piper-server start`
- `piper-server status`
- `piper-server stop`

`--faster` reduces `PIPER_LENGTH_SCALE` by `0.1` and saves it back to `~/.config/piper-speak/config.env`. `--slower` increases it by `0.1` and also saves it. For example, `1.0` becomes `0.9` after `speak --faster`, and `1.0` becomes `1.1` after `speak --slower`.

The default local workflow uses:

```bash
PIPER_MODE="http"
```

With the default config, SpeakSelect binds Piper to:

```text
127.0.0.1:5000
```

That means:

- only the same machine can connect to it
- you do not need to open firewall rules
- you should not bind it to `0.0.0.0`
- it is not intended to stream results to another computer

If you want to change the port locally, edit:

```bash
PIPER_HTTP_PORT="5000"
```

in `~/.config/piper-speak/config.env` and restart the server.

Then start the server:

```bash
piper-server start
```

If you prefer the older per-run behavior, switch back to:

```bash
PIPER_MODE="cli"
```

SpeakSelect does not install a `systemd --user` service yet. In this phase, server startup remains a manual `piper-server start` and `piper-server stop` workflow.

More detail: [docs/configuration.md](/home/pip/AAA_Builds/speakselect/docs/configuration.md)

## Local Server Commands

Use these to manage the local Piper process:

```bash
piper-server start
piper-server status
piper-server logs
piper-server stop
```

Useful checks:

```bash
speak --check-server
speak --print-config
```

## Voice Switching

List voices:

```bash
speak --list-voices
```

Set a new default voice:

```bash
speak --set-voice en_US-lessac-medium
```

Then download it if needed:

```bash
python3 -m piper.download_voices --data-dir "$HOME/.local/share/piper" en_US-lessac-medium
```

## Keyboard Shortcut Binding

The recommended shortcut is `Ctrl+Alt+Space`.

The installed command is:

```bash
~/.local/bin/speak-selection
```

For a visible troubleshooting window, run:

```bash
~/.local/bin/speak-selection-debug
```

GNOME steps and Wayland/X11 notes are in [docs/keyboard-shortcuts.md](/home/pip/AAA_Builds/speakselect/docs/keyboard-shortcuts.md).

You can also print a local reminder with:

```bash
print-shortcut-instructions.sh
```

## Troubleshooting

Common issues are documented in [docs/troubleshooting.md](/home/pip/AAA_Builds/speakselect/docs/troubleshooting.md).

The short version:

- If `speak` says Piper is missing, run `python3 -m pip install --user --upgrade 'piper-tts[http]' pathvalidate`
- If `speak --check-server` fails in HTTP mode, run `piper-server start`
- The local HTTP server binds to `127.0.0.1:5000` by default and is not intended for remote streaming or exposed ports
- If playback fails, make sure `ffplay` exists
- If `speak-selection` is silent, try `speak-selection --debug`
- If you want a visible debug window, run `speak-selection-debug`
- If the voice is missing, re-run `./install.sh --voice YOUR_VOICE`
- If the command is not found, add `~/.local/bin` to `PATH`

## Uninstall

Remove installed scripts:

```bash
./uninstall.sh
```

Also remove config and the current voice:

```bash
./uninstall.sh --remove-config --remove-voice
```

## Acknowledgements

SpeakSelect is a thin wrapper around the upstream Piper project and the tooling around it. This repo was made possible by:

- [OHF-Voice/piper1-gpl](https://github.com/OHF-Voice/piper1-gpl), the upstream Piper engine and CLI
- The Piper voice catalog, downloader, and HTTP server exposed by Piper
- `ffmpeg`/`ffplay`, `wl-clipboard`, and `xclip`

Upstream Piper is licensed under GPL-3.0. This repository does not bundle Piper source code; it installs Piper separately as a dependency. The SpeakSelect wrapper code in this repository is licensed under MIT. If you redistribute Piper itself, bundled binaries, or voice files, review the upstream licenses carefully.

## License

This repository is licensed under the MIT License. See [LICENSE](/home/pip/AAA_Builds/speakselect/LICENSE).
