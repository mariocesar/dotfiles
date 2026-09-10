# CLAUDE.md

A DankMaterialShell (DMS) bar widget: the pill shows the current or next
meeting; its popout lists today's agenda with Refresh and Settings rows. The
repo root `CLAUDE.md` applies — edit here, never under `$HOME`.

The widget is a front end for `linux/.local/bin/agenda`, which owns the JSON
contract (`agenda --format json`: `headline`, `today_label`, `now`, `current`,
`next`, `today`) and the config file (`agenda config`). A change to the script's
output and to the widget that parses it belong in one commit.

## Dev loop

`install.py` symlinks this directory to
`~/.config/DankMaterialShell/plugins/agenda`, so edits here are already live.
Only a **new file** needs `python3.13 install.py`.

Reload after a change: `dms ipc call plugins reload agenda` (also loads an
unloaded plugin). QML failures are silent — the widget just doesn't appear. The
shell runs under `dms.service` from `/usr/share/quickshell/dms`; never start a
second `qs`. Errors:

```bash
journalctl --user -u dms.service -o cat --since "HH:MM:SS"
```

The popout cannot be opened headlessly, so event rows, link clicks, Refresh and
Settings are tested by hand. Script changes: `uvx ruff check --config ruff.toml
linux/.local/bin/agenda` and `agenda --format json | python3.13 -m json.tool`.
Exercise `agenda config` only with a stub `xdg-open` first on `PATH` and
`XDG_CONFIG_HOME` pointed at a scratch dir — the real one opens an editor.

## Where the real documentation is

The list in `../airpods/CLAUDE.md` — DMS sources under
`/usr/share/quickshell/dms`, `PLUGINS/README.md`, `THEME_REFERENCE.md`, and the
grimblast plugin as the pill + popout template. Add `Common/Proc.qml`
(`runCommand` debouncing) and `Modules/Plugins/PluginPopout.qml` (injects
`closePopout`, rebinds the popout height).

## Facts that cost time

**The plugin lifecycle IPC target is `plugins`, not `widget`.** `dms ipc call
plugins list|status|enable|disable|toggle|reload <id>`. `widget` is bar-widget
visibility; `widget reload` answers "Function not found". In `DMSShellIPC.qml`
the `target:` line sits at the *end* of each `IpcHandler`, so grepping `-A`
from it shows the next handler's functions.

**A new plugin needs a scan before it can be enabled:** `dms ipc call
plugin-scan scan`, debounced, so wait ~3 s before `plugins list`. PluginService
only walks directories and reads `<dir>/plugin.json`; a real dir of symlinked
files, as `install.py` makes, is fine. Putting the widget on a bar is a
`settings.json` edit (`barConfigs[].centerWidgets` gets `{"id": "agenda",
"enabled": true}`); enabling persists in `plugin_settings.json`, written by DMS
over IPC only.

**Two bar configs means two widget instances** — `Plugin loaded: agenda` logs
twice. `Proc.runCommand` keys its debouncer by id in a singleton, and a shared
id hands every instance's data to the last caller's callback, so the fetch id is
per instance. Reloading one plugin also logs unload/load lines for the others;
those are not errors. A clean load logs exactly one `DankBar: Plugin loaded:
agenda` per bar and nothing else.

**`dcal sync` returns before the daemon syncs** ("sync started in the running
dcal daemon"), with no completion signal short of a streaming subscription —
hence the 3 s settle timer before the re-fetch.

**Screenshots:** `grim` rejects `-o` together with `-g`; DP-1 is at logical
0,0, so `grim -g "0,0 1920x64" bar.png` captures bar 0.

**Ruff is only on `uvx`.** The repo's `ruff.toml` selects Bandit's `S603`/`S607`,
which flag every argv-list `subprocess` call; the script and `install.py` both
trip them at HEAD. Not suppressed here — that is a `ruff.toml` decision.
