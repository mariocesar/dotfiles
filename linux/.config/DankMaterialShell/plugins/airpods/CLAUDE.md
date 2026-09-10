# CLAUDE.md

A DankMaterialShell (DMS) plugin: one bar widget, in QML, that indicates the
AirPods audio profile and switches it. The repo root `CLAUDE.md` still applies —
edit here, never under `$HOME`; comments stay terse. This file adds what is
specific to the plugin.

No build step, no tests. You verify by loading it into the running shell and
looking at `pactl`.

## Dev loop

`install.py` symlinks this directory to
`~/.config/DankMaterialShell/plugins/airpods`, so edits here are already live.
Only a **new file** needs an `install.py` run — `AirpodsWidget.qml` will, once.

QML failures are silent; the widget just doesn't appear. The shell runs from
`/usr/share/quickshell/dms` under `dms.service` — never start a second `qs`. To
see why:

```bash
journalctl --user -fu dms.service -o cat | grep PluginService
```

Reload after a change: `dms ipc call plugins reload airpods`, or Settings →
Plugins → the reload control. `plugins reload` also loads an unloaded plugin;
`plugin-scan scan` only discovers new manifests and loads nothing it already
knows.

Confirm state from the system, never by reading the QML back:

```bash
pactl list cards | grep -E 'Name: bluez_card|Active Profile'
pactl list sources short                  # bluez_input.* exists only in HFP
```

## Where the real documentation is

DMS is installed at `/usr/share/quickshell/dms` (root-owned, read-only).

- `PLUGINS/README.md` — 1774-line authoring guide. Read it before guessing.
- `PLUGINS/plugin-schema.json` — the `plugin.json` schema.
- `PLUGINS/THEME_REFERENCE.md` — `Theme` property names. It is `fontSizeSmall`,
  not `fontSizeS`.
- `Modules/Plugins/PluginComponent.qml` — the base type and its full contract.
- `~/.config/DankMaterialShell/plugins/grimblast/Grimblast.qml` — 317 lines, the
  closest working template for a pill plus popout menu.

## Facts that cost time to learn

**Switch profiles by calling the `airpods` script. Never `pactl
set-card-profile` directly.** A bare switch back to `a2dp-sink` while an SCO
voice link is up is refused by these AirPods — that is the whole reason
`linux/.local/bin/airpods` exists. It tears the link down with
`wpctl set-profile <id> 0`, issues `ConnectProfile` on the A2DP UUID, retries,
falls back to a full reconnect, and sets the default source in call mode. DMS's
own `BluetoothService.switchCodec()` is a thin `pactl set-card-profile` wrapper
and hits exactly that failure. Use
`Proc.runCommand("airpods.action", ["airpods", "call"], cb, 0, Proc.noTimeout)` —
the default 10 s timeout kills the script mid-switch.

Because the script lives in this same repo, a change to its output format and
the widget that parses it belong in one commit. That is why this is not a
separate repo.

**The session PATH comes from a zsh login shell, not `.zshrc`.** GDM spawns the
session through a non-interactive login shell and `niri-session` imports its
environment into the user manager, which is what `dms.service` and every niri
spawn inherit. `PATH` is therefore exported in `common/.zprofile`; without it a
bare `["airpods", …]` in `Proc.runCommand` fails with not found.
`environment.d` cannot do this job: `import-environment` overrides generators.

**Read the active profile from PipeWire node properties, not by polling.** The
bluez node carries it:

```qml
readonly property var node: Pipewire.nodes.values.find(n =>
    n.properties?.["api.bluez5.address"] === dev.address && n.isSink)
readonly property bool hfp: (node?.properties?.["api.bluez5.profile"] ?? "").startsWith("headset")
```

`properties` is only populated while a node is bound, so keep a
`PwObjectTracker` alive in the plugin. DMS itself re-runs `pactl list cards`
instead; don't copy that.

**Quickshell's PipeWire binding cannot set a profile.** It exposes nodes and
links only — no device or card object, no `setProfile`. An external command is
mandatory, which is another reason the script is the right dependency.

**There is no battery percentage, and this was tested — do not retry it.**
Enabling bluez's experimental D-Bus interfaces (`bluetoothd -E`) really does
expose `org.bluez.BatteryProviderManager1`, and restarting WirePlumber really
does re-register against it, but no `org.bluez.Battery1` ever appears on the
device in either profile and `pw-dump` stays empty. PipeWire implements Apple's
**HFP** battery extension (`AT+XAPL` / `AT+IPHONEACCEV`); AirPods report over the
**AAP** L2CAP channel, PSM 0x1001, which nothing in this stack speaks. `PLAN.md`
step 0 has the full trace.

**Do not reinstall LibrePods to get battery.** It exposes no D-Bus interface,
socket, CLI state query or REST endpoint — there is nothing to talk to. It was
removed from this machine deliberately: its BLE scan stranded the Bluetooth
mouse, it restarted WirePlumber, and it forced `sbc_xq` over the AAC preference.

**Never trigger a Bluetooth discovery scan.** Any `StartDiscovery` on this
adapter strands the bonded MX Master 3 mouse for up to a minute. This widget has
no reason to scan — pair elsewhere.

## Conventions

- Root the widget at `PluginComponent`; declare **both** `horizontalBarPill` and
  `verticalBarPill`.
- Size from the inherited readonly `iconSize` and
  `Theme.barTextSize(barThickness, barConfig?.fontScale)`. Never hardcode px —
  the pill has to track bar thickness.
- Hide optional pill elements with `visible:`, not by zeroing width. A hidden
  child leaves the `Row` layout and the pill shrinks on its own.
- Prefer a property binding over a timer. Most state here is reactive already.
- Failures are reported by the script's `notify-send`, which fires on every
  outcome. No `ToastService` on top of it — that shows the same failure twice.
