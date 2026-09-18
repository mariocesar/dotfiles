# World Clock

Search **World Clock** in the DMS launcher to open a floating dialog. The first
configured city is home. Today spans that city's midnight to the next midnight;
Around now spans 12 elapsed hours on either side of now. Reopening resets to Today.
All rows use the same real-time axis. Drag the bars horizontally (or use the
horizontal scrollbar); city labels stay fixed. Wheel vertically or use the vertical
scrollbar to see more cities. Escape, Close, and clicking outside dismiss the dialog.

The dialog fetches on opening, mode changes, Refresh, and every minute while open.
Every fetch reloads configuration. Failed updates retain a clearly marked stale
result. Settings creates and opens the TOML file with `xdg-open`, like Agenda.

## CLI and configuration

The CLI lives at `common/.local/bin/worldclock` and installs on both macOS and
Linux. It requires Python 3.11+ and the system timezone database; no Python
packages, network, or DMS are needed. `worldclock config` uses macOS's `open` or
Linux's `xdg-open`. Both platforms use the same configuration path and JSON format.

```sh
worldclock
worldclock --format ansi
worldclock --format plain
worldclock --mode around-now
worldclock --format json --mode today
worldclock --format json --mode around-now
worldclock config
```

Terminal output uses ANSI colors automatically on a TTY and plain text when
piped. `NO_COLOR` disables automatic colors; `--format ansi` explicitly enables
them. Colored bands share the same axis, with a bright Now marker, date-change
marks, and a legend. Hour labels use compact 24-hour numbers; repeated DST hours
also have an explicit offset-qualified note below the bar.

Configuration lives at `$XDG_CONFIG_HOME/worldclock/config.toml`, defaulting to
`~/.config/worldclock/config.toml`. It is personal data outside this repository.
A missing file uses the defaults below without creating it. An empty TOML file
also uses defaults; `cities = []` explicitly clears the list and shows setup guidance.

```toml
[[cities]]
label = "Santa Cruz de la Sierra"
timezone = "America/La_Paz"

[[cities]]
label = "Valencia"
timezone = "Europe/Madrid"
working_hours = ["09:00", "17:00"]

[[cities]]
label = "Kathmandu"
timezone = "Asia/Kathmandu"
working_hours = ["22:00", "06:00"]
```

Without `working_hours`, shading is day 08–18, morning/evening 06–08 and 18–22,
and night 22–06. An override replaces that city's shading with working/outside
work. Windows repeat every day, may cross midnight, and include their start but
exclude their end. Both values must be distinct 24-hour `HH:mm` times; `24:00`
is not accepted. There are no weekday or holiday schedules.

Timezone names, config structure and working hours are validated. Failures report
the config path and correction guidance on stderr and exit nonzero, leaving JSON
stdout empty. `config` preserves an existing file, including an invalid one.

## JSON contract

`worldclock --format json` produces one object:

| Field | Meaning |
| --- | --- |
| `generated_at` | Generation instant in UTC ISO 8601 |
| `mode` | `today` or `around-now` |
| `timeline` | `start`, `end` (UTC ISO 8601), `duration_seconds`, `now_position`; null with no cities |
| `message` | Setup guidance with no cities, otherwise empty |
| `cities` | Configured rows in order |

Each row contains `label`, `timezone`, `home`, current local `time` (`HH:mm`),
`date` (`YYYY-MM-DD`), `abbreviation`, and `utc_offset`. `offset_from_home_seconds`
and its signed `offset_from_home` label describe the difference **at generation
time**, which may change elsewhere in the displayed interval. `working_hours`
is either the configured pair or null.

| Row field | Entries |
| --- | --- |
| `ticks` | `position`, UTC `instant`, `label`, `utc_offset` for each actual local whole hour |
| `date_boundaries` | `position`, new local `date` at each date change |
| `segments` | `start`, `end`, `kind`: `day`, `twilight`, `night`, `working`, or `outside` |

All positions are fractions of elapsed time over the shared interval, from 0 to 1.
Segments partition the whole interval without gaps. Date boundaries and hour ticks
include the interval endpoints when applicable. Skipped hours have no tick;
repeated hours have separate ticks and offset-qualified labels. Today can have
23 or 25 hours, or a fractional duration in zones with half-hour DST changes.
QML only places supplied positions; it does no timezone arithmetic.

## Install and reload

For the CLI on macOS or Linux, run from the repository root:

```sh
python3.13 install.py --fake
python3.13 install.py
worldclock
```

The `python3` on PATH must be Python 3.11 or newer. If macOS still resolves it to
Apple's older Python, select a newer version with your Python manager or run
`python3.13 ~/.local/bin/worldclock` explicitly.

The DMS interface is Linux-only. After installing on Linux:

```sh
dms ipc call plugin-scan scan
# Wait about three seconds for the scan.
dms ipc call plugins enable worldclock
dms ipc call plugins status worldclock
```

The manifest provides one daemon and one launcher surface with an empty trigger.
No bar widget is needed. The launcher requests opening through PluginService's
`setGlobalVar` / `globalVarChanged`; the daemon waits for the launcher's dismissal
animation before opening its single DankModal. DMS persists enablement itself.

Existing file edits are live through symlinks. Reload with:

```sh
dms ipc call plugins reload worldclock
journalctl --user -u dms.service -o cat --since "5 minutes ago"
```

For diagnosis, `dms ipc call worldclock open|close|refresh|status` is available;
`dms ipc call worldclock mode around-now` switches the open dialog. `status`
reports visibility, polling, mode, fetch state, error and generation instant.
Do not start another DMS shell to check QML.

## Manual verification

Use temporary files, without adding a repository test suite. Parse JSON in both
modes and inspect the terminal bars. Import the CLI with `runpy.run_path`, then
call `build_data(cities, mode, now)` with fixed aware instants. Check Madrid's
spring/fall DST days (23/25 hours and skipped/repeated 02:00), Lord Howe's half-hour
transition, Kathmandu's quarter-hour offset, and midnight rollover against La Paz.
Check that segments cover [0, 1], default shading follows local wall time, and
daytime/overnight working-hour overrides replace it.

Use a scratch `XDG_CONFIG_HOME` and a stub opener (`open` on macOS, `xdg-open` on
Linux) on PATH for config creation, preservation and opener checks. Exercise empty cities and invalid TOML, timezone,
and working-hour values. In DMS check launcher search and keyboard focus, Escape,
outside click, both modes, horizontal/vertical scrolling, Refresh, and reopening.
Inspect service logs and compare `status` while closed for more than a minute:
polling should remain false and `generated_at` unchanged.
