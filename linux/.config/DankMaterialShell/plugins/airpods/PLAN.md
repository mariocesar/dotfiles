# AirPods widget: build plan

Build a DMS bar widget that shows the active AirPods audio profile and switches
it from a click menu. Self-contained — everything needed to execute it is here or
in `CLAUDE.md`.

Target:

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

Settled decisions — do not relitigate these while building:

- **Click always opens the menu.** No click-to-toggle, no accidental profile
  flips. `Mod+Shift+A` already covers the fast path.
- **Hide completely when disconnected.** The pill collapses and the bar closes
  up.
- **Icon only, no battery %.** Tested and unavailable — see step 0.
- **The `airpods` script does the switching.** This widget is a front end.

## How to work

- **One commit per lettered item.** The shell must still start and the widget
  still render after every commit.
- **Verify against the running shell, not by reading.** Every item has a check
  that inspects `pactl` output or the visible bar. QML fails silently; a widget
  that "looks right" in the file may not have loaded at all.
- **Do not refactor beyond the item.** No service singletons, no settings panel,
  no variants, no abstraction over the one device. This is one widget.
- **Read `CLAUDE.md` first** — this directory's, and the repo root's.

Setup: nothing to do. `install.py` has already symlinked this directory into
place, so edits are live. Keep this running in a terminal to see load errors:

```bash
qs -v -p ~/.config/quickshell/dms/shell.qml
```

## Step 0 — battery: settled, the answer is no

**Tested 2026-09-10. AirPods battery is not available on this machine. Do not
retry this; the widget is icon-only.**

What was tried, in order — every link worked except the last:

1. `bluetoothd --experimental` via a `bluetooth.service` drop-in. This is the
   D-Bus switch (`-E`), not the kernel one (`-K`). It worked:
   `org.bluez.BatteryProviderManager1` appeared on `/org/bluez/hci0`, where it
   had not existed before.
2. WirePlumber restarted so it would re-register against the newly available
   interface. It came back and re-created the card.
3. Retested in `headset-head-unit`, with the HFP channel actually up.

Result: no `org.bluez.Battery1` on the device in either profile, and nothing
battery-shaped anywhere in `pw-dump`. Nothing registers a battery provider for
these AirPods.

The likely reason is structural rather than configuration. PipeWire implements
Apple's **HFP** battery extension (`AT+XAPL` / `AT+IPHONEACCEV` — the strings are
in `libspa-bluez5.so`), but AirPods report battery over the **AAP** L2CAP
channel, PSM 0x1001. That is the proprietary protocol LibrePods reverse
engineered, and nothing in the bluez/PipeWire stack speaks it. Enabling
interfaces cannot conjure a number the device never sends over that path.

Unproven only in that it was not confirmed by tracing the RFCOMM channel, but it
fits every observation. The `45-bluetooth-experimental.sh` hook written for the
experiment was removed afterwards rather than left carrying an experimental
interface nothing uses.

Reopen only if PipeWire gains AAP support upstream. Do not reinstall LibrePods —
`CLAUDE.md` explains why.

## A. A pill that appears

`plugin.json` is written. Add `AirpodsWidget.qml` rooted at `PluginComponent`
with a hardcoded `DankIcon { name: "earbuds" }` in both `horizontalBarPill` and
`verticalBarPill`. No logic yet.

This is a new file, so it needs one `python3.13 install.py` run before the shell
can see it. Everything after this item is live-on-save.

Imports needed across the whole widget:

```qml
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.Common      // Theme, Proc, I18n
import qs.Services    // BluetoothService, ToastService
import qs.Widgets     // DankIcon, StyledText, StyledRect
import qs.Modules.Plugins
```

Size from the inherited readonly `iconSize`, never a literal.

**Check:** `ls -l ~/.config/DankMaterialShell/plugins/airpods/AirpodsWidget.qml`
points into `.dotfiles`. Settings → Plugins lists *AirPods*; enabling it and
dragging it onto a bar puts a visible earbuds glyph there, with no
`PluginService:` error in `qs -v`.

## B. Find the device, hide when it is gone

Do **not** hardcode the MAC. The bluez PipeWire sink node carries the address,
and it is the same node item C needs:

```qml
readonly property var node: Pipewire.nodes.values.find(n =>
    n.isSink && n.properties?.["api.bluez5.address"] !== undefined)
readonly property string mac: node?.properties?.["api.bluez5.address"] ?? ""
readonly property var dev: mac ? (BluetoothService.adapter?.devices?.values
    ?.find(d => (d.address || "").toUpperCase() === mac.toUpperCase()) ?? null) : null
```

Keep a tracker alive or `properties` stays empty:

```qml
PwObjectTracker { objects: Pipewire.nodes.values.filter(n => n.audio && !n.isStream) }
```

Guard everything on `dev?.connected`. Null-guard `BluetoothService.adapter` — it
is `Bluetooth.defaultAdapter` and is null briefly at startup.

Hide via `visible:` on the pill contents; reach for `PluginComponent`'s
`visibilityCommand` only if that proves insufficient.

**Check:** `bluetoothctl disconnect 6C:12:70:3C:5F:0D` → the pill disappears and
the widgets beside it close up. Reconnect → it returns. `qs -v` clean across
both transitions.

## C. Live profile, reflected in the icon

```qml
readonly property string profile: node?.properties?.["api.bluez5.profile"] ?? ""
readonly property string codec: node?.properties?.["api.bluez5.codec"] ?? ""
readonly property bool hfp: profile.startsWith("headset")
```

Icon becomes `hfp ? "headset_mic" : "earbuds"`. Both names are confirmed present
in the Material Symbols codepoints DMS ships; verify any other name against
`/usr/share/quickshell/dms/assets/fonts/material-design-icons/` before using it.

No timer, no polling — these are notifying properties.

**Check:** run `airpods call` in a terminal; the bar icon flips within a second
with no interaction. `airpods music`; it flips back. Cross-check against
`pactl list cards | grep -A1 bluez_card`.

## D. The menu

Declare `popoutContent` — `PluginComponent` wires the click to it automatically
as long as `pillClickAction` stays unset. Root at `PopoutComponent` for the
header and close button, then a `Column` of three rows built from `StyledRect` +
`MouseArea`, following `grimblast/Grimblast.qml:177-316`.

Rows: **Music** (`airpods music`), **Call** (`airpods call`), **Reconnect**
(`airpods reconnect`). Show the live codec next to the active row and mark it;
derive "active" from `hfp`, not from what was last clicked.

```qml
Proc.runCommand("airpods.action", ["airpods", "call"], (out, code) => {
    if (code !== 0) ToastService.showError("AirPods switch failed", out)
}, 0)
```

Call the injected `closePopout()` after acting. `PluginPopout` already handles
Escape and click-outside.

**Check:** clicking the pill opens the menu; Music/Call change `Active Profile`
and the icon follows. Escape and click-outside both dismiss. **Run Music while a
call is live** — that is the SCO-teardown path the script exists for, and the
case a naive `pactl` call fails.

## E. Battery — dropped

Step 0 settled this: the number is not available. Left as a lettered slot so the
other items keep their labels. Nothing to build.

## F. Polish

Vertical pill layout (`Column` instead of `Row`) for a side bar; hover state on
the menu rows; `DankIcon.filled` on the active row. Confirm the pill still looks
right with the bar's `noBackground: true` and `squareCorners: true`, which is
how bar 2 is configured.

**Check:** temporarily move the widget to a vertical bar, confirm it renders,
move it back.

## G. Clean up the LibrePods leftovers

Not this directory — DMS's own state, which is untracked.

`barConfigs[1].rightWidgets` in `~/.config/DankMaterialShell/settings.json`
still holds `{"id": "librepods", "enabled": true}`, and `plugin_settings.json`
still holds `"librepods": {"enabled": true}`. Both are dead entries from
`083b800 Simpler airpod flow`. Remove them when adding this widget to the bar —
it takes the same slot.

**Check:** `grep -c librepods ~/.config/DankMaterialShell/*.json` returns 0, and
the bar renders unchanged apart from the new widget.

## Done when

- The pill appears only with AirPods connected, and its icon always matches
  `pactl list cards`.
- The menu switches both directions reliably, including music-while-on-a-call.
- A failed switch surfaces as a toast rather than silence.
- `qs -v` is clean across connect, disconnect and both switches.
