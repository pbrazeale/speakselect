# Troubleshooting

## `ModuleNotFoundError: pathvalidate`

Install the Python dependencies again:

```bash
python3 -m pip install --user --upgrade 'piper-tts[http]' pathvalidate
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

If you are using HTTP mode, restart the local server after changing voices:

```bash
piper-server stop
piper-server start
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

## HTTP Server Not Running

- If `PIPER_MODE="http"`, check the server with `speak --check-server`
- Start it with `piper-server start`
- Inspect the current state with `piper-server status`
- Read recent server logs with `piper-server logs`

## HTTP Connection Errors

- Confirm `PIPER_HTTP_HOST` and `PIPER_HTTP_PORT` in `~/.config/piper-speak/config.env`
- Run `speak --check-server`
- If the server is stopped, run `piper-server start`
- If the server returns an error, inspect `piper-server logs`

## Wayland Selection Issues

- Install `wl-clipboard`
- Try `speak-selection --debug`
- If you want SpeakSelect to open its own visible debug terminal, run `speak-selection-debug`
- Look for the reported source in debug output, such as `wayland-primary`
- The default `primary-only` mode does not fall back to clipboard automatically
- If you want clipboard fallback, run `speak-selection --prefer-primary` or set `SELECTION_SOURCE_MODE="prefer-primary"` in `~/.config/piper-speak/config.env`
- Some sandboxed apps expose clipboard content differently than native apps

## Shortcut Opens a Terminal

- Bind `speak-selection`, not `speak-selection-debug`, for the normal desktop shortcut
- Use `speak-selection-debug` only when you want a visible troubleshooting window
- In GNOME custom shortcuts, bind the command directly instead of launching it through a terminal app

## Slow Startup

CLI mode loads the model on each run. If you want to avoid that repeated startup cost, switch to `PIPER_MODE="http"` and run the local Piper server with `piper-server start`.
