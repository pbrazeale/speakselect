# Configuration

SpeakSelect loads its runtime settings from:

```bash
~/.config/piper-speak/config.env
```

Default contents:

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
SELECTION_RETRY_COUNT="3"
SELECTION_RETRY_DELAY_MS="50"
```

## Variables

- `PIPER_DATA_DIR`: Directory containing downloaded `.onnx` and `.onnx.json` voice files
- `PIPER_VOICE`: Voice basename without the file extension
- `PIPER_LENGTH_SCALE`: Piper speed/length scale. Lower values are faster. Higher values are slower
- `PIPER_PYTHON`: Python interpreter used for `python -m piper` and `python -m piper.download_voices`
- `PIPER_MODE`: Runtime mode. `http` uses the local Piper HTTP server. `cli` uses direct per-run Piper invocation as a fallback
- `PIPER_HTTP_HOST`: Host interface for the Piper HTTP server. Keep this on loopback only
- `PIPER_HTTP_PORT`: Port used by the Piper HTTP server
- `PIPER_HTTP_VOICE`: Voice used when `speak` sends HTTP synthesis requests
- `SELECTION_SOURCE_MODE`: Selected-text capture policy. Supported values are `primary-only`, `clipboard-only`, `prefer-primary`, and `prefer-clipboard`
- `SELECTION_RETRY_COUNT`: How many times SpeakSelect checks the primary selection before giving up
- `SELECTION_RETRY_DELAY_MS`: Delay in milliseconds between primary-selection retries

## Runtime Modes

The default local workflow is:

```bash
PIPER_MODE="http"
```

SpeakSelect is designed to run this server on the same machine only. Keep `PIPER_HTTP_HOST` on `127.0.0.1`, `localhost`, or `::1`. You do not need to open firewall ports for local use.

Current default HTTP settings:

```bash
PIPER_MODE="http"
PIPER_HTTP_HOST="127.0.0.1"
PIPER_HTTP_PORT="5000"
PIPER_HTTP_VOICE="en_GB-southern_english_female-low"
```

Then start the local server:

```bash
piper-server start
```

Check reachability:

```bash
speak --check-server
```

Stop the server:

```bash
piper-server stop
```

## Config Migration

If you rerun `./install.sh` on top of an older config, SpeakSelect now:

- preserves existing values already present in `config.env`
- appends any missing settings required by newer versions
- writes a backup to `config.env.bak` before modifying the file

That means older installs can pick up HTTP and selection-policy settings without losing customized voice or speed values. If `PIPER_MODE` was missing, migration now appends the local HTTP default.

## Selection Capture Policy

The default selection mode is:

```bash
SELECTION_SOURCE_MODE="primary-only"
```

That means `speak-selection` reads highlighted text and fails if no highlighted text is available. It does not silently speak stale clipboard content by default.

If you want fallback behavior, choose one of these modes:

- `prefer-primary`: try highlighted text first, then clipboard
- `prefer-clipboard`: try clipboard first, then highlighted text
- `clipboard-only`: only read the clipboard

You can also override the mode for a single run:

```bash
speak-selection --prefer-primary
speak-selection --prefer-clipboard
```

## Helpful Commands

Print the resolved config:

```bash
speak --print-config
```

List voices:

```bash
speak --list-voices
```

Switch voices:

```bash
speak --set-voice en_US-lessac-medium
python3 -m piper.download_voices --data-dir "$HOME/.local/share/piper" en_US-lessac-medium
```

Override the speed for one run:

```bash
speak --speed 0.9 "This will speak a bit faster"
```
