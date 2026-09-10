# AirPods widget: build plan

Build a DMS bar widget that shows the active AirPods audio profile and switches
it from a click menu. Self-contained — everything needed to execute it is here or
in `CLAUDE.md`.

Target:

```
bar 2 (left)        click ->
  ┌────┐              ┌────────────────────────┐
  │ …  │              │ AirPods Pro            │
  │ 🎧 │              │ ────────────────────── │
  │ ⌨  │              │ 🎧  Music      AAC   ● │
  │ 🔔 │              │ 🎙  Call       HFP     │
  │ ⚙  │              │ ────────────────────── │
  └────┘              │ ↻   Reconnect          │
                      └────────────────────────┘
```

Settled decisions — do not relitigate these while building:

- **Click always opens the menu.** No click-to-toggle, no accidental profile
  flips. `Mod+Shift+A` already covers the fast path.
- **Hide completely when disconnected.** The pill collapses and the bar closes
  up.
- **Icon only, no battery %.** Tested and unavailable — see step 0.
- **The `airpods` script does the switching.** This widget is a front end.
- **It lives on bar 2, a left vertical bar**, in the slot `librepods` held.
  `verticalBarPill` is the live path from item A on; the horizontal pill is
  secondary.

## How to work

- **One commit per lettered item.** The shell must still start and the widget
  still render after every commit.
- **Verify against the running shell, not by reading.** Every item has a check
  that inspects `pactl` output or the visible bar. QML fails silently; a widget
  that "looks right" in the file may not have loaded at all.
- **Do not refactor beyond the item.** No service singletons, no settings panel,
  no variants, no abstraction over the one device. This is one widget.
- **Read `CLAUDE.md` first** — this directory's, and the repo root's.
- **Items B–D need the AirPods connected.** `pactl list cards short | grep
  bluez` confirms silently — `airpods status` notifies through `die` when they
  are off. Without them there is no bluez card, no node, and nothing to check.

Setup: done on 2026-09-10 — `~/.local/bin` is on the session PATH. It was not:
GDM spawns the session through a non-interactive zsh login shell, `niri-session`
then imports that shell's environment into the user manager, and the only
`PATH` export lived in `.zshrc`, which login shells never read. So `dms.service`
could not find `airpods` (`Proc.runCommand` runs its array with no shell), and
niri worked around it three times with `$HOME/.local/bin/…`. The export now
lives in `common/.zprofile`. An `environment.d` entry was tried first and is
dead here: `import-environment` wins over environment generators.

For the current session the user manager's PATH was set by hand; a re-login
makes it permanent. niri's three workarounds can drop the prefix after that,
outside this plan.

**Check:** after `systemctl --user restart dms.service` (the whole shell, bar
included), the running shell's PATH starts with `.local/bin`:

```bash
tr '\0' '\n' < /proc/$(pgrep -f 'qs -p /usr/share/quickshell/dms')/environ | grep ^PATH
```

The shell runs from `/usr/share/quickshell/dms` under `dms.service` — never
start a second `qs`. Keep this running in a terminal to see load errors:

```bash
journalctl --user -fu dms.service -o cat | grep PluginService
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

`plugin.json` is written; rename its `requires` key to `dependencies` — the
schema marks `requires` a deprecated alias. Registry metadata only: PluginService
reads neither key, so no dependency check runs. Add `AirpodsWidget.qml` rooted at
`PluginComponent` with a hardcoded `DankIcon { name: "earbuds" }` in both
`horizontalBarPill` and `verticalBarPill`. No logic yet.

This is a new file, so it needs one `python3.13 install.py` run before the shell
can see it. Everything after this item is live-on-save.

Then seat and enable it — the `settings.json` half of item G lands here because
the widget takes the `librepods` slot. Settings window closed, since DMS
rewrites the file on any settings change:

- `settings.json`: in `barConfigs[1].rightWidgets`, change the `librepods`
  widget id to `airpods`. Bar slots reference plugins by bare id, so the rename
  is enough, and DMS re-reads this file on change.
- `dms ipc call plugins enable airpods`. This creates the `airpods` entry in
  `plugin_settings.json` itself; `plugin-scan scan` only loads manifests it has
  not seen before.

Do not hand-edit `plugin_settings.json`: DMS reads it once at startup and
rewrites it from memory on every plugin setting change, so the edit is undone
by the next write. The dead `librepods` key there is G.

Imports needed across the whole widget:

```qml
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.Common      // Theme, Proc
import qs.Services    // BluetoothService
import qs.Widgets     // DankIcon, StyledText, StyledRect
import qs.Modules.Plugins
```

Size from the inherited readonly `iconSize`, never a literal.

**Check:** `ls -l ~/.config/DankMaterialShell/plugins/airpods/AirpodsWidget.qml`
points into `.dotfiles`. An earbuds glyph sits on the left bar,
`grep -c librepods ~/.config/DankMaterialShell/settings.json` returns 0, and
there is no `PluginService:` error in the journal.

## B. Find the device, hide when it is gone

Do **not** hardcode the MAC. Presence comes from Bluetooth, profile from
PipeWire — never presence from PipeWire: every profile switch destroys and
recreates the node, `airpods music` holds the card at profile `off` for seconds
while it repairs A2DP, and a card left at `off` has no node at all. bluez
reports `audio-headphones` for the AirPods and `input-mouse` for the MX Master,
and Quickshell's `BluetoothDevice` exposes that as `icon`:

```qml
readonly property var dev: BluetoothService.devices?.values
    ?.find(d => d.connected && (d.icon ?? "").startsWith("audio-")) ?? null
readonly property bool connected: dev !== null
readonly property var node: dev ? (Pipewire.nodes.values.find(n =>
    n.isSink && n.properties?.["api.bluez5.address"] === dev.address) ?? null) : null
```

Only `connected` drives visibility. `connected && !node` is a real state — card
`off`, or mid-switch — not "gone"; item C gives it a look.

Keep a tracker alive or `properties` stays empty:

```qml
PwObjectTracker { objects: Pipewire.nodes.values.filter(n => n.audio && !n.isStream) }
```

`BluetoothService.devices` is null until `Bluetooth.defaultAdapter` appears at
startup; the `?.` chain covers it.

Hide with `PluginComponent`'s `setVisibilityOverride(connected)`, called from
`onConnectedChanged` and once in `Component.onCompleted`. It is the only
mechanism that collapses the pill to zero width: `visible: false` on the
contents leaves a padding-only stub about 24 px wide, and `visibilityCommand`
polls a shell command on a timer. `setVisibilityOverride` is not in the README
and DMS's IPC widget show/hide shares it; both are acceptable here.

**Check:** `bluetoothctl disconnect 6C:12:70:3C:5F:0D` → the pill disappears and
the widgets beside it close up. Reconnect → it returns. Journal clean across
both transitions.

## C. Live profile, reflected in the icon

```qml
readonly property string profile: node?.properties?.["api.bluez5.profile"] ?? ""
readonly property string codec: node?.properties?.["api.bluez5.codec"] ?? ""
readonly property bool hfp: profile.startsWith("headset")
```

Icon becomes `hfp ? "headset_mic" : "earbuds"`. While `connected && !node` the
profile string is empty, so the icon falls to `earbuds`; colour it
`Theme.surfaceVariantText` in that state so a card stuck at `off` is visible
and a switch in progress reads as one. Both names are confirmed present
(`earbuds` f003, `headset_mic` e311); verify any other name against the
codepoints file DMS ships:

```
/usr/share/quickshell/dms/assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].codepoints
```

No timer, no polling — these are notifying properties.

**Check:** run `airpods call` in a terminal; the bar icon flips within a second
with no interaction. `airpods music`; it flips back. Cross-check against:

```bash
pactl list cards | grep -E 'Name: bluez_card|Active Profile'
```

In music the node's `api.bluez5.profile` reads `a2dp-sink` and the codec `aac`
— lowercase. In call it reads `headset-head-unit` and a `bluez_input.*` source
appears in `pactl list sources short`.

## D. The menu

Declare `popoutContent` — `PluginComponent` wires the click to it automatically
as long as `pillClickAction` stays unset. Root at `PopoutComponent` for the
header and close button, then a `Column` of three rows built from `StyledRect` +
`MouseArea`, following `grimblast/Grimblast.qml:177-316`.

Rows: **Music** (`airpods music`), **Call** (`airpods call`), **Reconnect**
(`airpods reconnect`). Show the live codec next to the active row, as
`codec.toUpperCase()` since PipeWire reports `aac`, and mark it; derive
"active" from `hfp`, not from what was last clicked.

```qml
property bool busy: false

function run(action) {
    busy = true
    Proc.runCommand("airpods.action", ["airpods", action], () => {
        busy = false
    }, 0, Proc.noTimeout)
}
```

No toast. The script `notify-send`s every outcome, failures included via
`die`, and DMS is the notification server — a `ToastService` call here would
show the same failure twice, and the script is the side that knows why.

`Proc.noTimeout` is not optional. The default is 10 s, and on timeout Proc
kills the process and reports code 124. `airpods music` from a live call can
legitimately take ~30 s (profile off, `ConnectProfile`, up to 12 s wait, then a
reconnect and another 12 s), and `reconnect` ~15 s. With the default the script
dies mid-switch, the card is left at `off`, and no notification ever fires.
Disable the rows while `busy` so two scripts never fight over `wpctl`.

`busy` resets only in the callback, and that is enough: every wait in the
script is a bounded loop, so it always returns. `Mod+Shift+A` runs the script
outside the widget and bypasses `busy`; that collision is the same as two
terminals and is out of this widget's scope.

Call the injected `closePopout()` after acting. `PluginPopout` already handles
Escape and click-outside. Do not set `popoutHeight` or copy Grimblast's
hardcoded `baseHeight` — `PluginPopout` rebinds its height to the content's
`implicitHeight` once loaded.

**Check:** clicking the pill opens the menu; Music/Call change `Active Profile`
and the icon follows. Escape and click-outside both dismiss. **Run Music while a
call is live** — that is the SCO-teardown path the script exists for, and the
case a naive `pactl` call fails.

## E. Battery — dropped

Step 0 settled this: the number is not available. Left as a lettered slot so the
other items keep their labels. Nothing to build.

## F. Polish

The vertical `Column` pill is what items A–D already render, so this is the
horizontal `Row` layout for a top bar; hover state on the menu rows;
`DankIcon.filled` on the active row. Both bars use `noBackground: true` and
`squareCorners: true`, so that is the only look to confirm.

**Check:** temporarily add `{"id": "airpods", "enabled": true}` to Main Bar's
`rightWidgets`, confirm the pill renders, remove it.

## G. Clean up the LibrePods leftovers

Not this directory — DMS's own state, which is untracked. The `settings.json`
half is done in A. `plugin_settings.json` still holds `"librepods":
{"enabled": true}`, dead since `083b800 Simpler airpod flow`, and DMS puts it
back on every write because it only reads the file at startup. Remove the key
and restart the shell in one go, at a quiet moment:

```bash
jq 'del(.librepods)' ~/.config/DankMaterialShell/plugin_settings.json > /tmp/ps.json \
  && mv /tmp/ps.json ~/.config/DankMaterialShell/plugin_settings.json \
  && systemctl --user restart dms.service
```

**Check:** `grep -c librepods ~/.config/DankMaterialShell/*.json` returns 0 and
stays 0 after `dms ipc call plugins disable airpods` then `enable`, which
forces a DMS write.

## Done when

- The pill appears only with AirPods connected, and its icon always matches
  `pactl list cards | grep -E 'Name: bluez_card|Active Profile'`.
- The menu switches both directions reliably, including music-while-on-a-call.
- A failed switch surfaces as the script's notification rather than silence.
- The journal is clean across connect, disconnect and both switches.
