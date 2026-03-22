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
```

## Variables

- `PIPER_DATA_DIR`: Directory containing downloaded `.onnx` and `.onnx.json` voice files
- `PIPER_VOICE`: Voice basename without the file extension
- `PIPER_LENGTH_SCALE`: Piper speed/length scale. Lower values are faster. Higher values are slower
- `PIPER_PYTHON`: Python interpreter used for `python -m piper` and `python -m piper.download_voices`

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
