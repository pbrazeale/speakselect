# Architecture Direction

SpeakSelect now supports both the original per-run CLI path and a local client/server model.

## Current State

- `speak` invokes Piper directly on each request.
- model load happens on every invocation
- `speak-selection` captures text locally and forwards it to `speak`
- `PIPER_MODE="http"` enables a local Piper HTTP server with `piper-server`

## Target State

- a long-lived local Piper HTTP server keeps the voice model loaded
- `speak` acts as a local client
- `speak-selection` remains responsible for text capture and delegates playback requests through `speak`

## Current Rollout Status

- `PIPER_MODE="cli"` remains the migration-safe default
- `PIPER_MODE="http"` is implemented and uses `piper-server` for lifecycle management
- the long-term direction is to make the server/client path the preferred default after more stabilization

## Why This Change

- lower repeated startup cost
- clearer separation of concerns
- better fit for keyboard-shortcut usage where responsiveness matters

## Work Tracking

Implementation planning and phased execution live under `/todo/`:

- `/todo/spec.md`
- `/todo/phase_01.md`
- `/todo/phase_02.md`
- `/todo/phase_03.md`
- `/todo/phase_04.md`
- `/todo/phase_05.md`

Keep this page updated as implementation decisions change.
