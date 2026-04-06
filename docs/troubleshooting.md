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

By default, the local server URL is:

```text
http://127.0.0.1:5000/
```

## Local-Only HTTP Mode

- SpeakSelect is intended to run the Piper HTTP server on the same machine only
- Keep `PIPER_HTTP_HOST` set to `127.0.0.1`, `localhost`, or `::1`
- The default bind is `127.0.0.1:5000`
- Do not bind the server to `0.0.0.0` or another external interface
- You do not need to open firewall ports for the local workflow
- If you changed the port, confirm it matches `PIPER_HTTP_PORT` in `~/.config/piper-speak/config.env`

## HTTP Connection Errors

- Confirm `PIPER_HTTP_HOST` and `PIPER_HTTP_PORT` in `~/.config/piper-speak/config.env`
- Run `speak --check-server`
- If the server is stopped, run `piper-server start`
- If the server returns an error, inspect `piper-server logs`
- If you changed host or port recently, restart the server so the running process matches the config

## Upgrade or Config Migration Problems

- Rerun `./install.sh` to append any missing config keys for newer versions
- Check `~/.config/piper-speak/config.env.bak` if you need to compare pre-migration settings
- Fresh installs now default to `PIPER_MODE="http"` for the local server/client path
- `systemd --user` service files are not installed yet in this phase; manage the server manually with `piper-server start` and `piper-server stop`

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

## Wrong Text Was Spoken

- The default `SELECTION_SOURCE_MODE` is now `primary-only`
- That means SpeakSelect reads highlighted text and stops if no primary selection is available
- It no longer silently falls back to clipboard contents in the default configuration
- If you want clipboard fallback, use `speak-selection --prefer-primary` or set `SELECTION_SOURCE_MODE="prefer-primary"`
- If behavior still looks wrong, run `speak-selection --debug` and inspect the reported source such as `wayland-primary` or `x11-primary`

## Slow Startup

CLI mode loads the model on each run. The default local workflow uses `PIPER_MODE="http"` with `piper-server start`. Switch back to `PIPER_MODE="cli"` only if you prefer the older per-run behavior.
