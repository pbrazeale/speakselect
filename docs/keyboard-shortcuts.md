# Keyboard Shortcuts

The recommended binding is `Ctrl+Alt+Space`.

If you want the shortcut to open a terminal window and show the captured text before speaking, use `speak-selection --window` instead of plain `speak-selection`.

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

Or, to force a popup terminal window:

```text
Name: Speak Selection
Command: ~/.local/bin/speak-selection --window
Shortcut: Ctrl+Alt+Space
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

If you want the shortcut itself to open a visible terminal, bind it to:

```bash
speak-selection --window
```
