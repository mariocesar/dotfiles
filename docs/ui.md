# UIs

For web or tui interfaces.

## Look

- Calm and focused, with a TUI feel: monospace, panes, a status line.
- 1px hairlines. No filled bars, hard offset shadows or uppercase labels.
- One quiet accent. In `share`, the cursor row has a soft `--sel` fill and a 2px ochre line on its left edge.
- One monospace font, JetBrains Mono, with system fallbacks. `share` uses the installed copy; the public /uses page loads it from Google Fonts.
- `font-variant-ligatures: none`, so code fonts show `>=` as typed.

## Colors

[Azulejo Brutalism](https://github.com/VerticalHeretic/AzulejoBrutalism), in light and dark following `prefers-color-scheme`. Use the theme's colors, not its loudest expression.

| token       | light                | dark                |
| ----------- | -------------------- | ------------------- |
| `--bg`      | `#F3F0E8` glaze      | `#0C1030` ink       |
| `--fg`      | `#0C1030`            | `#F3F0E8`           |
| `--muted`   | `#5A5E78`            | `#8A8FB5`           |
| `--primary` | `#1E2A9E` cobalt     | `#9FB2E4` wash      |
| `--ochre`   | `#D49A1A`            | `#D49A1A`           |

`share` adds `--bg-alt`, `--sel`, `--line`, `--fg-dim`, `--faint` and four state colors (`--red`, `--green`, `--purple`, `--teal`). Copy them from its `CSS` block rather than inventing new ones.

## Behavior

- Keyboard first, vim-style: `j`/`k` move, `g`/`G` jump to the ends, `l`/`h` go in and out, `Esc` closes, `?` lists every key.
- Works on a phone: fullscreen, and under 760px the side pane becomes a drawer while the preview takes the whole screen.
- A page served by a local script loads no inline script and no third-party asset, under a strict Content-Security-Policy.
