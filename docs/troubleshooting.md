# Troubleshooting

## `ModuleNotFoundError: pathvalidate`

Install the Python dependencies again:

```bash
python3 -m pip install --user --upgrade piper-tts pathvalidate
```

## No Sound

- Confirm `ffplay` exists: `command -v ffplay`
- Test your audio stack with another local audio file
- Re-run `speak --print-config` and make sure the voice files exist in `PIPER_DATA_DIR`

## Voice Not Found

Download the configured voice again:

```bash
python3 -m piper.download_voices --data-dir "$HOME/.local/share/piper" en_GB-southern_english_female-low
```

Or use the installer:

```bash
./install.sh --voice en_GB-southern_english_female-low
```

## `ffplay` Missing

Install `ffmpeg`, then verify:

```bash
command -v ffplay
```

## `~/.local/bin` Not On `PATH`

Add this to your shell profile:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then open a new shell or source your profile.

## Wayland Selection Issues

- Install `wl-clipboard`
- Try `speak-selection --debug`
- If primary selection is unavailable, copy the text first so clipboard fallback has something to read
- Some sandboxed apps expose clipboard content differently than native apps

## Slow Startup

Piper CLI loads the model on each run. That is expected in this simple CLI wrapper. SpeakSelect keeps the simpler WAV plus `ffplay` flow for reliability, not long-lived process reuse.
