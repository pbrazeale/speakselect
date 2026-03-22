# SpeakSelect

<p align="center">
  <img src="./speakselect_logo.webp" alt="SpeakSelect logo" width="220">
</p>

SpeakSelect packages the [Piper CLI](https://github.com/OHF-Voice/piper1-gpl) into two small Linux-first commands:

- `speak "hello world"`
- `speak-selection`

The project stays CLI-based. It does not run a Piper server, does not depend on shell functions in `~/.bashrc`, and keeps the important logic in readable Bash scripts that you can copy to another machine if you prefer manual installation.

## Features

- One-command install with `./install.sh`
- Standalone `speak` command for direct text or stdin
- Standalone `speak-selection` command for highlighted text on Wayland or X11
- Config file at `~/.config/piper-speak/config.env`
- Default voice set to `en_GB-southern_english_female-low`
- WAV output plus `ffplay` playback for predictable local audio
- Helper commands for testing, voice listing, and keyboard shortcut setup

## Demo Usage

```bash
speak "hello world"
printf 'hello from stdin\n' | speak
speak --list-voices
speak --faster
speak --slower
speak --set-voice en_US-lessac-medium
speak-selection --debug
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
python3 -m pip install piper-tts pathvalidate
```

It then downloads a voice with Piper's documented downloader.

## Quick Install

```bash
git clone <your-repo-url>
cd speakselect
chmod +x install.sh
./install.sh
```

Then test it:

```bash
speak "hello"
```

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
python3 -m pip install --user --upgrade piper-tts pathvalidate
```

3. Download the default voice:

```bash
python3 -m piper.download_voices --data-dir "$HOME/.local/share/piper" en_GB-southern_english_female-low
```

4. Copy the scripts:

```bash
mkdir -p "$HOME/.local/bin"
install -m 0755 bin/speak "$HOME/.local/bin/speak"
install -m 0755 bin/speak-selection "$HOME/.local/bin/speak-selection"
install -m 0755 scripts/detect-selection.sh "$HOME/.local/bin/detect-selection.sh"
install -m 0755 scripts/test-voice.sh "$HOME/.local/bin/test-voice.sh"
install -m 0755 scripts/print-shortcut-instructions.sh "$HOME/.local/bin/print-shortcut-instructions.sh"
```

5. Create your config:

```bash
mkdir -p "$HOME/.config/piper-speak"
cp config/piper-speak.env.example "$HOME/.config/piper-speak/config.env"
```

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
```

Useful commands:

- `speak --print-config`
- `speak --list-voices`
- `speak --faster`
- `speak --slower`
- `speak --set-voice en_US-lessac-medium`

`--faster` reduces `PIPER_LENGTH_SCALE` by `0.1` and saves it back to `~/.config/piper-speak/config.env`. `--slower` increases it by `0.1` and also saves it. For example, `1.0` becomes `0.9` after `speak --faster`, and `1.0` becomes `1.1` after `speak --slower`.

More detail: [docs/configuration.md](/home/pip/AAA_Builds/speakselect/docs/configuration.md)

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

GNOME steps and Wayland/X11 notes are in [docs/keyboard-shortcuts.md](/home/pip/AAA_Builds/speakselect/docs/keyboard-shortcuts.md).

You can also print a local reminder with:

```bash
print-shortcut-instructions.sh
```

## Troubleshooting

Common issues are documented in [docs/troubleshooting.md](/home/pip/AAA_Builds/speakselect/docs/troubleshooting.md).

The short version:

- If `speak` says Piper is missing, run `python3 -m pip install --user --upgrade piper-tts pathvalidate`
- If playback fails, make sure `ffplay` exists
- If `speak-selection` is silent, try `speak-selection --debug`
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
- The Piper voice catalog and downloader exposed by `python3 -m piper.download_voices`
- `ffmpeg`/`ffplay`, `wl-clipboard`, and `xclip`

Upstream Piper is licensed under GPL-3.0. This repository does not bundle Piper source code; it installs Piper separately as a dependency. The SpeakSelect wrapper code in this repository is licensed under MIT. If you redistribute Piper itself, bundled binaries, or voice files, review the upstream licenses carefully.

## License

This repository is licensed under the MIT License. See [LICENSE](/home/pip/AAA_Builds/speakselect/LICENSE).
