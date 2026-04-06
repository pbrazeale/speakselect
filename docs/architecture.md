# Architecture Direction

SpeakSelect now supports both the original per-run CLI path and a local client/server model.

## Current State

- `PIPER_MODE="http"` is now the default local workflow
- `speak` acts as a local HTTP client when running in the default mode
- `cli` mode still invokes Piper directly on each request as a fallback
- `speak-selection` captures text locally and forwards it to `speak`
- `PIPER_MODE="http"` enables a local Piper HTTP server with `piper-server`

## Default Local Topology

The normal runtime topology is intentionally small:

1. `piper-server` starts Piper's HTTP server on `127.0.0.1:5000`
2. `speak` sends text to that loopback endpoint
3. Piper returns WAV audio
4. `speak` plays the result locally with `ffplay`
5. `speak-selection` stays focused on text capture and delegates synthesis to `speak`

This is a local process boundary, not a network-distributed system. The HTTP interface is used as a stable local API between the Bash entrypoints and the long-lived Piper process.

## Target State

- a long-lived local Piper HTTP server keeps the voice model loaded
- `speak` acts as a local client
- `speak-selection` remains responsible for text capture and delegates playback requests through `speak`
- the local endpoint remains loopback-only rather than becoming a LAN or public service

## Current Rollout Status

- `PIPER_MODE="http"` is now the preferred default for local use
- `PIPER_MODE="http"` uses `piper-server` for lifecycle management on loopback only
- `PIPER_MODE="cli"` remains available as a compatibility fallback

## Why This Change

- lower repeated startup cost
- clearer separation of concerns
- better fit for keyboard-shortcut usage where responsiveness matters
- local-only loopback binding avoids remote exposure and does not require opening public network ports

## Why Not a Remote Server

This repo does not need cross-machine playback routing. The user interaction is local: highlight text on this machine, synthesize on this machine, and play audio on this machine. Keeping the server on `127.0.0.1:5000` avoids a few classes of problems:

- no firewall or router setup
- no accidental exposure of a synthesis endpoint
- no confusion about where audio is generated and played
- simpler install and support model

## Work Tracking

Implementation planning and phased execution live under `/todo/`:

- `/todo/spec.md`
- `/todo/phase_01.md`
- `/todo/phase_02.md`
- `/todo/phase_03.md`
- `/todo/phase_04.md`
- `/todo/phase_05.md`

Keep this page updated as implementation decisions change.
