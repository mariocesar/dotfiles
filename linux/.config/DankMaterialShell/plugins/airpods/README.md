# AirPods widget

A DankMaterialShell bar widget: shows which AirPods audio profile is active, and
switches between them from a click menu.

```
bar:   [ …  🎧  ⌨  🔔  ⚙ ]

click ->
   ┌────────────────────────┐
   │ AirPods Pro            │
   │ ────────────────────── │
   │ 🎧  Music      AAC   ● │
   │ 🎙  Call       HFP     │
   │ ────────────────────── │
   │ ↻   Reconnect          │
   └────────────────────────┘
```

The pill hides completely when the AirPods are disconnected.

## Why

AirPods have no A2DP microphone. Opening an input drops the whole device to
8 kHz mono HFP, so `51-bluez-airpods.conf` turns
`bluetooth.autoswitch-to-headset-profile` off and the profile is switched
deliberately instead. That makes the profile a sticky, invisible mode — you
discover which one you're in when a call has no microphone. This makes it
visible and one click away.

It is a front end for `linux/.local/bin/airpods` and does not reimplement
profile switching. `CLAUDE.md` explains why that matters.

## Install

`install.py` symlinks this directory to
`~/.config/DankMaterialShell/plugins/airpods` like any other config. Then:
Settings → Plugins → Scan for Plugins → enable **AirPods**, and
Settings → Widgets → drag it into a bar section.

Edits here are live afterwards — the installed path is a symlink back to the
repo, so only a shell reload is needed, not a re-install.

## No battery percentage

AirPods report battery over Apple's proprietary AAP L2CAP channel, which nothing
in the bluez/PipeWire stack speaks. `PLAN.md` step 0 records the test that
established this; it is settled, not a to-do.

## Status

Early — the manifest and docs are in place, the QML is not. See `PLAN.md`.
