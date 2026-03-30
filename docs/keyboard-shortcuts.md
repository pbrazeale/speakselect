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

- On X11, `speak-selection` reads the primary selection with `xclip` and falls back to the clipboard
- On Wayland, it uses `wl-paste --primary` first and then falls back to the clipboard
- Some Wayland apps and compositors do not expose the primary selection consistently; if nothing is read, copy the text to the clipboard and try again

## Debugging a Silent Shortcut

Run this in a terminal:

```bash
speak-selection --debug
```

If that works, the command is installed correctly and the remaining issue is usually desktop shortcut configuration or selection access.

If you want the shortcut itself to open a visible terminal, bind it to:

```bash
speak-selection --window
```
