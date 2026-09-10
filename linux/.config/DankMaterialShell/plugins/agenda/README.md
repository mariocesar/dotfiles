# Agenda

A DankMaterialShell bar widget: the pill shows the current or next meeting,
clicking it opens today's agenda. An event row opens its meeting link (or the
calendar link) with `xdg-open`; Refresh re-syncs dcal; Settings opens the
script's config file.

It is only a front end for `linux/.local/bin/agenda`, which owns the filtering
and the configuration (`agenda config`). The widget runs `agenda --format json`
every minute and when the menu opens, and renders what it gets.

## Install

```bash
python3.13 install.py
```

Then Settings → Plugins → enable Agenda, and Settings → Widgets → drag it into
a bar. The installed path is a symlink into this repo, so later edits are live;
reload with `dms ipc call plugins reload agenda`.
