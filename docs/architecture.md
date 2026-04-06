# Architecture Direction

SpeakSelect now supports both the original per-run CLI path and a local client/server model.

## Current State

- `PIPER_MODE="http"` is now the default local workflow
- `speak` acts as a local HTTP client when running in the default mode
- `cli` mode still invokes Piper directly on each request as a fallback
- `speak-selection` captures text locally and forwards it to `speak`
- `PIPER_MODE="http"` enables a local Piper HTTP server with `piper-server`

## Target State

- a long-lived local Piper HTTP server keeps the voice model loaded
- `speak` acts as a local client
- `speak-selection` remains responsible for text capture and delegates playback requests through `speak`

## Current Rollout Status

- `PIPER_MODE="http"` is now the preferred default for local use
- `PIPER_MODE="http"` uses `piper-server` for lifecycle management on loopback only
- `PIPER_MODE="cli"` remains available as a compatibility fallback

## Why This Change

- lower repeated startup cost
- clearer separation of concerns
- better fit for keyboard-shortcut usage where responsiveness matters
- local-only loopback binding avoids remote exposure and does not require opening public network ports

## Work Tracking

Implementation planning and phased execution live under `/todo/`:

- `/todo/spec.md`
- `/todo/phase_01.md`
- `/todo/phase_02.md`
- `/todo/phase_03.md`
- `/todo/phase_04.md`
- `/todo/phase_05.md`

Keep this page updated as implementation decisions change.
