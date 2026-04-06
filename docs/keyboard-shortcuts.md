# Keyboard Shortcuts

The recommended binding is `Ctrl+Alt+Space`.

Bind `speak-selection` directly for normal use. Keep debugging separate from the everyday shortcut path.

The normal shortcut flow is local only:

1. the shortcut runs `speak-selection`
2. `speak-selection` reads the current primary selection
3. the text is sent to the local `speak` command
4. `speak` talks to the local Piper server on `127.0.0.1:5000` by default
5. audio plays on the same machine

No remote server is required for the recommended setup.

## GNOME

1. Open `Settings`
2. Go to `Keyboard`
3. Open `View and Customize Shortcuts`
4. Scroll to `Custom Shortcuts`
5. Choose `Add Shortcut`
6. Use:

```text
Name: Speak Selection
Command: ~/.local/bin/speak-selection
Shortcut: Ctrl+Alt+Space
```

For manual debugging, run this in a terminal:

```bash
~/.local/bin/speak-selection --debug
```

If you specifically want SpeakSelect to open its own debug terminal window, run:

```bash
~/.local/bin/speak-selection-debug
```

If your desktop does not expand `~`, replace it with the absolute path from:

```bash
command -v speak-selection
```

## X11 vs Wayland

- On X11, `speak-selection` reads the primary selection with `xclip`
- On Wayland, it uses `wl-paste --primary`
- The default mode is `primary-only`, so the shortcut now fails clearly if highlighted text is unavailable instead of silently reading clipboard text
- If you want clipboard fallback, set `SELECTION_SOURCE_MODE="prefer-primary"` in your config or bind a mode-specific command such as `speak-selection --prefer-primary`
- Some Wayland apps and compositors do not expose the primary selection consistently; use `speak-selection --debug` to see the exact source that was used

## Debugging a Silent Shortcut

Run this in a terminal:

```bash
speak-selection --debug
```

The debug output now includes the exact selection source, such as `wayland-primary` or `x11-primary`.

If that works, the command is installed correctly and the remaining issue is usually desktop shortcut configuration or selection access.

If you want SpeakSelect itself to open a visible debug terminal window, run:

```bash
speak-selection-debug
```
