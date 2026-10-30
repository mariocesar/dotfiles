---
name: audit
description: Read-only health audit of this machine — Arch/CachyOS + niri on Linux, MacBook Pro on macOS — plus the Neovim and Claude Code setups on both — returning a ranked list of issues to work on. Detects the OS and runs the matching checks.
argument-hint: "[window, e.g. -3d on Linux or 3d on macOS]"
disable-model-invocation: true
allowed-tools: Bash(uname:*), Bash(journalctl:*), Bash(systemctl:*), Bash(coredumpctl:*), Bash(systemd-analyze:*), Bash(jq:*), Bash(sensors:*), Bash(pacdiff -o), Bash(checkupdates), Bash(fwupdmgr get-updates:*), Bash(df:*), Bash(free:*), Bash(ss:*), Bash(/usr/bin/log:*), Bash(launchctl:*), Bash(last:*), Bash(nvram -p), Bash(pmset -g:*), Bash(system_profiler:*), Bash(softwareupdate --list), Bash(brew doctor), Bash(brew outdated), Bash(brew leaves), Bash(brew missing), Bash(brew cleanup -s --dry-run), Bash(pkgsync -n), Bash(sysupgrade -n), Bash(du:*), Bash(find:*), Bash(mdfind:*), Bash(mdutil -s:*), Bash(vm_stat), Bash(memory_pressure), Bash(sysctl:*), Bash(uptime), Bash(lsof:*), Bash(ps:*), Bash(ls:*), Bash(test:*), Bash(plutil -extract:*), Bash(pkgutil --pkgs:*), Bash(tmutil listlocalsnapshots:*), Bash(docker system df), Bash(spctl --status), Bash(osascript:*), Bash(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate), Bash(nvim --version), Bash(nvim --headless:*), Bash(mktemp:*), Bash(git -C:*), Bash(grep:*), Bash(sort:*), Bash(wc:*), Bash(which -a claude), Bash(claude --version), Bash(claude mcp list), Bash(npm ls -g:*)
---

# /audit

Run `uname -s` first. `Linux` → **Linux audit** below. `Darwin` → **macOS audit** below. Follow only the matching section, but before its Rank step also run **Neovim** and **Claude Code** at the end, which apply to both. Their findings go into the same ranked list.

**Read-only, on both.** Fix nothing, and don't ask to during the audit. There is no passwordless sudo: list root-only checks at the end as `! <command>` for the user to run.

`logdrain` is often not on the tool PATH; use `~/.cargo/bin/logdrain`.

Read memory for items already diagnosed or accepted (e.g. PSI IO inflated by Ghostty's io_uring). Report them as *known*, not as new findings, unless they got worse.

---

## Linux audit (Arch/CachyOS + niri)

Audit window: `$ARGUMENTS`, or `-7d` if empty. Call it `SINCE` below.

### 1. Hard failures

- `journalctl --list-boots | head -3`: journald is capped at 50M, so the window may be shorter than `SINCE`. Say so if it is.
- `systemctl --failed`; `systemctl --user --failed`
- `coredumpctl list --since SINCE`
- Unclean shutdowns: for each boot in the window, `journalctl -b <idx> -n 15 -o short-monotonic`. A clean one ends `Reached target System Reboot`/`System Power Off` … `Journal stopped`; anything else is a crash or power loss.
- `journalctl -k -p 3 --since SINCE`: filesystem, NVMe, MCE and GPU errors go straight to tier 1.
- Pending reboot: `uname -r` vs `pacman -Q linux-cachyos`, and `head -1 /proc/driver/nvidia/version` vs `pacman -Q nvidia-utils`. A mismatch is a reboot owed; `NVRM: API mismatch` in the journal is the same thing seen from the logs.

### 2. Journal patterns (logdrain)

System and user journals together, warning and above, grouped into templates:

```sh
journalctl -p 4 --since SINCE -o json --no-pager -q \
  | jq -c '{m: ((.PRIORITY // "?") + " " + (.SYSLOG_IDENTIFIER // ._COMM // "?") + ": " + (.MESSAGE|tostring)), t: (.__REALTIME_TIMESTAMP|tonumber)}' \
  | ~/.cargo/bin/logdrain --key m --time-key t --masks ipv4,uuid,hex32 --min-size 2 --format jsonl \
  | jq -r '[.size, (.eventRatePerMinute // 0 | . * 1000 | round / 1000), .eventLastSeen, .template[0:180]] | @tsv'
```

Session services (niri, dms, espanso, autostart apps) log to stdout at priority 5–6 with ANSI colours, so `-p 4` misses them:

```sh
journalctl --user -p 5..6 --since SINCE -o json --no-pager -q \
  | jq -c 'select(.MESSAGE|type=="string") | .MESSAGE |= gsub("\u001b\\[[0-9;]*m"; "")
           | select(.MESSAGE|test("WARN|ERROR|panic|fail"; "i"))
           | {m: ((._SYSTEMD_USER_UNIT // .SYSLOG_IDENTIFIER // "?") + ": " + .MESSAGE), t: (.__REALTIME_TIMESTAMP|tonumber)}' \
  | ~/.cargo/bin/logdrain --key m --time-key t --masks ipv4,uuid,hex32 --min-size 1 --format jsonl \
  | jq -r '[.size, .eventLastSeen, .template[0:180]] | @tsv'
```

For each template worth ranking, drill in before naming a cause: `journalctl -b -g '<distinctive text>' -n 20`, and check whether `eventLastSeen` (epoch ms) is recent (still happening) or stale.

### 3. System state

- Boot: `systemd-analyze`; `systemd-analyze blame | head -15`
- Timers: `systemctl list-timers --all`; `systemctl --user list-timers --all`. Look for `n/a` last runs.
- Packages: `pacdiff -o`; `checkupdates`; `grep -iE 'warning|error' /var/log/pacman.log | tail -40`; `pacman -Qdtq`
- Firmware: `fwupdmgr get-updates`
- Hardware: `sensors`; `cat /proc/pressure/{cpu,memory,io}`; `df -h / /home /boot`; `free -h`; `journalctl --disk-usage`
- Exposure: `systemctl is-active ufw`; `ss -tulpn` for listeners not bound to loopback
- Cruft: `find /var/log -maxdepth 1 -mtime +90`

### 4. Rank

Tiers, top to bottom:

1. **Critical**: risk of data loss, hardware fault, security exposure, crashes, unclean shutdowns.
2. **Broken**: something the user relies on doesn't work (failed unit, driver/API mismatch, audio or Bluetooth errors).
3. **Degraded / pending**: reboot pending, unmerged `.pacnew` with real changes, updates, slow boot, performance.
4. **Noise**: no visible effect. Worth fixing only when cheap, since silencing it keeps future audits readable.

Within a tier, rank higher when the issue is still happening, frequent, and cheap to fix.

Name where the cause lives (package, `/etc` file, a dotfiles path, firmware, hardware) and mark it *likely* unless you verified it. Don't prescribe a fix wider than the diagnosed cause.

### Output

```
## Audit — <window actually covered>

1. <title>  [tier] [still happening | stale]
   Evidence: <count, rate, one sample line or command result>
   Cause: <where it lives; likely/verified>
   Next: <one concrete step>  (needs root: yes/no)
…

Known / accepted: <items from memory, one line each>
Clean: <checks that found nothing, one line>
Needs root, run yourself: `! sudo smartctl -H -A /dev/nvme0n1`, …
```

End by asking which item to work on.

---

## macOS audit

Audit window: `$ARGUMENTS`, or `3d` if empty. Call it `SINCE` below — it feeds `log show --last SINCE`.

`log` is a zsh math builtin — always call `/usr/bin/log`, never bare `log`.

### 1. Hard failures

- `last reboot | head -3`: unified-log retention is disk-space-bounded, so the window may be shorter than `SINCE`. Say so if it is.
- `launchctl list | awk '$2 != 0 && $2 != "Status"'` — nonzero Status is a service that exited badly.
- Crash reports: `ls -lt ~/Library/Logs/DiagnosticReports/*.ips | head`. The system dir is root-only; list it under needs-root.
- Unclean shutdowns: interleave `last reboot | head -5` and `last shutdown | head -5`. A reboot with no shutdown between it and the previous boot is a crash or power loss.
- `nvram -p | grep -i panic` — panic flag from the last boot.
- `/usr/bin/log show --last SINCE --predicate 'messageType == 17' --style compact | head -40` — Faults are the macOS analog of `journalctl -p 3`; GPU, filesystem and driver faults go straight to tier 1.
- Pending restart: `softwareupdate --list` items marked `Action: restart` mean OS/firmware updates are owed a reboot.

### 2. Log patterns (logdrain)

Errors and Faults for the window, grouped into templates. ndjson timestamps are strings, hence the strptime dance:

```sh
/usr/bin/log show --last SINCE --predicate 'messageType == 16 OR messageType == 17' --style ndjson 2>/dev/null \
  | jq -c 'select(.eventMessage != null) | {m: ((.messageType // "?") + " " + ((.processImagePath // "?") | split("/") | last) + ": " + (.eventMessage|tostring)), t: ((.timestamp | sub("\\.[0-9]+"; "") | strptime("%Y-%m-%d %H:%M:%S%z") | mktime) * 1000)}' \
  | ~/.cargo/bin/logdrain --key m --time-key t --masks ipv4,uuid,hex32 --min-size 2 --format jsonl \
  | jq -r '[.size, (.eventRatePerMinute // 0 | . * 1000 | round / 1000), .eventLastSeen, .template[0:180]] | @tsv' | sort -rn | head -30
```

`log show` gets slow past a few days; if the window drags, run it once at `--last 1d` and say the window shrank.

For each template worth ranking, drill in before naming a cause: `/usr/bin/log show --last 1h --predicate 'processImagePath CONTAINS "<name>"' --style compact | head -20`, and check whether `eventLastSeen` (epoch ms) is recent (still happening) or stale.

### 3. System state

- Homebrew: `brew doctor`; `brew outdated`; `brew missing`; `pkgsync -n` for Brewfile drift.
- Battery: `pmset -g batt`; `system_profiler SPPowerDataType | grep -E 'Cycle Count|Condition|Maximum Capacity'`.
- Thermal: `pmset -g therm` — any recorded warning level is a finding.
- Disk and memory: `df -h / /System/Volumes/Data`; `vm_stat | head -8`; `memory_pressure | tail -1`; `sysctl vm.swapusage`.
- Exposure: `/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate`; `lsof -iTCP -sTCP:LISTEN -n -P`. `rapportd`, `ControlCe`, `AirPlay` binding `*` is stock Apple behaviour — flag only unrecognized processes.
- Integrity: `spctl --status` (Gatekeeper); `mdutil -s /` (Spotlight).
- Zombies: `ps -axo stat,pid,comm | awk '$1 ~ /^Z/'`.

### 4. Reclaimable space & leftovers

Space is not breakage: findings here are tier 3 at most, usually tier 4.

- Cache/junk sweep: `du -sh ~/Library/Caches ~/Library/Logs ~/.Trash ~/Library/Developer/Xcode/DerivedData ~/Library/Developer/CoreSimulator ~/.npm ~/.pnpm-store ~/Library/Caches/Homebrew ~/.cargo/registry ~/go/pkg/mod ~/Library/Application\ Support/MobileSync/Backup 2>/dev/null`
- `brew cleanup -s --dry-run | tail -3` — reclaimable without deleting.
- `docker system df` — skip silently if the daemon is down.
- Stray installers: `find ~/Downloads \( -name '*.dmg' -o -name '*.pkg' \) -mtime +30 -exec ls -lh {} +`
- Project artifacts: `find ~/Projects -maxdepth 4 -type d \( -name node_modules -o -name target -o -name dist \) -prune -print 2>/dev/null | head -20` then `du -sh` the hits.
- Large files: `mdfind 'kMDItemFSSize > 1073741824' -onlyin ~ | head -15` — Spotlight, cheap; don't walk with `find`.
- APFS snapshots pinning space: `tmutil listlocalsnapshots /`
- Dangling launch agents: for each plist in `~/Library/LaunchAgents /Library/LaunchAgents /Library/LaunchDaemons`, `plutil -extract Program raw` (falling back to `ProgramArguments.0`) and `test -e` the binary. A missing binary, or a label from no app in `/Applications` or `~/Applications`, is a leftover.
- Login items: `osascript -e 'tell application "System Events" to get the name of every login item'` — flag ones for absent apps.
- Orphaned data, top-N by size only: biggest entries of `du -sh ~/Library/Application\ Support/* ~/Library/Containers/* 2>/dev/null | sort -rh | head -15` that match no installed app. Don't build a full reverse index.
- Stale receipts: `pkgutil --pkgs | head -40` entries for software no longer present.

### 5. Rank

Tiers, top to bottom:

1. **Critical**: risk of data loss, hardware fault, security exposure, crashes, unclean shutdowns.
2. **Broken**: something the user relies on doesn't work (failed unit, driver/API mismatch, audio or Bluetooth errors).
3. **Degraded / pending**: reboot pending, updates, slow boot, performance, disk filling.
4. **Noise**: no visible effect. Worth fixing only when cheap, since silencing it keeps future audits readable.

Within a tier, rank higher when the issue is still happening, frequent, and cheap to fix.

Name where the cause lives (app, launchd plist, a dotfiles path, Homebrew package, firmware, hardware) and mark it *likely* unless you verified it. Don't prescribe a fix wider than the diagnosed cause.

### Output

```
## Audit — <window actually covered>

1. <title>  [tier] [still happening | stale]
   Evidence: <count, rate, one sample line or command result>
   Cause: <where it lives; likely/verified>
   Next: <one concrete step>  (needs root: yes/no)
…

Known / accepted: <items from memory, one line each>
Clean: <checks that found nothing, one line>
Needs root, run yourself: `! sudo sfltool dumpbtm`, `! diskutil verifyVolume /`, `! sudo pmset -g log | grep -i failure`, `! sudo ls -lt /Library/Logs/DiagnosticReports | head`
```

End by asking which item to work on.

---

## Neovim (both OSes)

The config is `home/common/.config/nvim`, shared by both machines. `lazy-lock.json` is a real file in `~/.config/nvim`, not tracked, so each machine pins its own plugin commits.

- Version: `nvim --version | head -1`. It is a nightly build; checkhealth reports how far behind it is.
- Health, headless. Checkhealth is async on 0.12+, so wait for the buffer to stop growing before writing it:

  ```sh
  d=$(mktemp -d)
  nvim --headless -c checkhealth \
    -c 'lua local n=-1; vim.wait(150000, function() local c=vim.api.nvim_buf_line_count(0); local done=(c==n and c>10); n=c; return done end, 3000)' \
    -c "w! $d/health.txt" -c 'qa!' >/dev/null 2>&1
  grep -E '^- (❌|⚠️) ' "$d/health.txt" | sort | uniq -c | sort -rn
  ```

  `ERROR` lines are findings. Ignore `Graphics protocol: not supported by this terminal` (headless has no terminal). Missing ruby/perl/node providers are tier 4, fixed by `vim.g.loaded_<name>_provider = 0` if nothing uses them. Anything under `vim.deprecated` is a plugin or config line that breaks on a future release.
- Startup: run `nvim --headless --startuptime "$d/st.log" +qa` three times and read the `NVIM STARTED` line; take the median. Over 100 ms is a finding, and the slowest `sourcing`/`require` lines (`sort -k2 -rn`) name the cause.
- Lockfile drift: every plugin in `lazy-lock.json` should be checked out at its locked commit, and nothing should be installed that the lockfile doesn't list:

  ```sh
  cd ~/.config/nvim
  jq -r 'to_entries[] | "\(.key) \(.value.commit[0:8])"' lazy-lock.json | while read -r n c; do
    h=$(git -C ~/.local/share/nvim/lazy/"$n" rev-parse --short=8 HEAD 2>/dev/null)
    [ "$h" = "$c" ] || echo "drift $n lock=$c installed=${h:-missing}"
  done
  ls ~/.local/share/nvim/lazy | while read -r p; do jq -e --arg p "$p" 'has($p)' lazy-lock.json >/dev/null || echo "not in lock: $p"; done
  ```
- State growth: `du -sh ~/.local/state/nvim/* ~/.local/share/nvim/* | sort -rh`. A log over 50M (`lsp.log` grows without bound) is a finding.
- Mason: `ls ~/.local/share/nvim/mason/packages` should match the `servers` list in `lua/lsp.lua` one to one (mason-lspconfig maps `ts_ls` → `typescript-language-server` and so on). A package with no server is leftover disk, often ~95M each for the node-based ones.

---

## Claude Code (both OSes)

`~/.claude/settings.json` is a real file Claude rewrites; its `hooks` are owned by `home/common/.claude/hooks.json` and merged in by `postinstall/common/80-claude-hooks.sh`.

- Install: `claude --version`; `which -a claude`. The native installer links `~/.local/bin/claude` into `~/.local/share/claude/versions/`. A second real binary (e.g. `npm ls -g @anthropic-ai/claude-code` lists one) is a finding; the same path printed twice is not.
- Model pins: `jq '.model, .env' ~/.claude/settings.json`. A `model` or `CLAUDE_CODE_SUBAGENT_MODEL` naming an older model than the latest of its family (the Environment section of your system prompt lists them) is a finding: tier 3, cheap.
- Settings integrity: `jq empty ~/.claude/settings.json` must pass, and `jq -e --slurpfile h ~/.claude/hooks.json '.hooks == $h[0]' ~/.claude/settings.json` must print `true`; `false` means hooks drifted from the repo and `install.py` needs a run.
- MCP: `claude mcp list` (health-checks each server over the network, takes a few seconds). `✘ Failed to connect` is a finding: a server that can never work still lists its name and instructions in every session's context. `! Needs authentication` on a server never used is tier 4. `✔ Connected` can be stale for expired auth, so don't count it as proof.
- Status line runs on every redraw: time `statusLine.command` with `echo '{}' | time sh -c '<cmd>'`; over 100 ms is a finding. Don't run hooks to time them (`notify.sh` pops a notification); read the scripts, and flag one on `PreToolUse`/`PostToolUse` that does network or heavy work, since it runs on every tool call.
- Context size: `wc -l ~/.claude/CLAUDE.md CLAUDE.md` and the project memory `MEMORY.md`. A CLAUDE.md over ~200 lines, or task-specific prose that belongs in a skill, is tier 4. `MEMORY.md` loads every session, so a line pointing to a missing memory file is noise to fix.
- Permissions: `jq -r '.permissions.allow[]' ~/.claude/settings.json | sort | uniq -d` (duplicates) and any `Bash(*)`-style blanket rule.
- Disk: `du -sh ~/.claude/{projects,debug,file-history,plugins} ~/.local/share/claude/versions; ls -l ~/.claude.json`. Transcripts older than `cleanupPeriodDays` (default 30) mean cleanup isn't running: `find ~/.claude/projects -name '*.jsonl' -mtime +30 | wc -l`. `~/.claude.json` over 1M is known to slow startup. Never suggest `cleanupPeriodDays: 0`, which disables transcripts instead of cleanup.
