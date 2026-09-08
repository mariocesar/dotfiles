# Neovim cheat sheet

Leader `,` · localleader `\` · visual-multi leader `\\` · reopen with `:Cheat`

## Understand unknown code

| | |
|---|---|
| `gd` `gD` | Definition / declaration |
| `<C-o>` `<C-i>` | Back / forward — works for *every* jump |
| `K` | Signature and docs |
| `grr` | References |
| `gO` | Symbol outline for the file |
| `gri` `grt` | Implementations / type definition |
| `:jumps` | Pick a spot instead of stepping back |

## Fix a diagnostic

| | |
|---|---|
| `]d` `[d` | Next / previous problem |
| `gra` | Code actions — Ruff autofixes live here |
| `grn` | Rename symbol across files |
| `,f` | Format buffer |
| `<C-W>d` | Float listing every diagnostic on the line |

Full message expands under the cursor line automatically, with rule code and
`help:` hint. So `]d` is all you need to read a truncated warning.

## Move in a file

| | |
|---|---|
| `<C-d>` `<C-u>` | Half page, recentred |
| `%` | Matching bracket / tag / keyword |
| `{` `}` | Previous / next blank line |
| `` `` `` | Position before the last jump |
| `an` `in` | Grow / shrink selection by syntax node |
| `]n` `[n` · `]N` `[N` | Next node · next sibling |

## Open and switch files

| | |
|---|---|
| `,p` | Fuzzy-find in project |
| `,d` | Fuzzy-find a dotfile |
| `]b` `[b` | Buffers |
| `]q` `[q` · `]l` `[l` | Quickfix · location list |
| `gx` | Open URL/path under cursor |
| `:Cwd` | cwd to current file's dir |

## Wrap, change, comment

| | |
|---|---|
| `cs"'` | Change surrounding `"` → `'` |
| `ds"` | Delete surrounding `"` |
| `ysiw"` | Surround inner word |
| `yss)` | Surround whole line |
| `S"` | Wrap selection (visual) |
| `ysiw<em>` | Wrap in an HTML tag |
| `gcc` · `gc` | Comment line · comment motion/selection |

`.` repeats any of these.

## Edit many places at once

| | |
|---|---|
| `<C-n>` | Select word, repeat for next occurrence |
| `\\A` | Select every occurrence |
| `<C-Down>` `<C-Up>` | Add cursor down / up |
| `\\\` | Add cursor here |
| `\\/` | Select by regex |
| `\\gS` | Restore last selection |

Then `c` `i` `A` `~` apply everywhere; `<Esc>` exits.
For symbols use `grn` instead — multi-cursor is for config, markup, columns.

## Macros

| | |
|---|---|
| `qa` … `q` | Record into register `a` |
| `@a` · `@@` | Play · replay the last one |
| `5@a` | Play 5 times |
| `999@a` | Play until it errors — stops at end of file |
| `:reg a` | See what you actually recorded |
| `"ap` … `"ay$` | Paste the macro to edit it, then store it back |

## Search and replace

| | |
|---|---|
| `/pat` · `n` `N` | Search · next / previous |
| `*` | Search word under cursor |
| `<Esc><Esc>` | Clear highlight |
| `:%s/old/new/g` | Replace in file |

Case-insensitive until you type a capital. `:%s` previews live in a split.

## Windows, tabs, terminal

| | |
|---|---|
| `,%` `,"` | Split vertical / horizontal |
| `,c` `,n` | New tab / next tab |
| `<C-w>` + `hjkl` | Move between splits |
| `,s` `,q` | Save / quit |
| `:Terminal` | Shell pane, persistent buffer |
| `:Run` · `:Config` · `:Reload` | Run file · edit init.lua · source it |

## Clipboard

`y` and `p` use the system clipboard. `<C-c>` copies a selection, `<D-v>` pastes.

## Git

`:Gitsigns preview_hunk` · `blame_line` · `diffthis`

## Troubleshoot

| | |
|---|---|
| `:checkhealth vim.lsp` | Attached servers, roots, why one didn't |
| `:Mason` · `:MasonLog` | Server installs · failures |
| `:Lazy` | Plugin status and load times |

