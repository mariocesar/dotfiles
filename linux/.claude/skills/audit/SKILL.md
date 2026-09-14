---
name: audit
description: Read-only health audit of this Arch/CachyOS + niri machine — journal, session services, systemd, pacman, hardware — returning a ranked list of issues to work on.
argument-hint: "[since, e.g. -3d]"
disable-model-invocation: true
allowed-tools: Bash(journalctl:*), Bash(systemctl:*), Bash(coredumpctl:*), Bash(systemd-analyze:*), Bash(jq:*), Bash(sensors:*), Bash(pacdiff -o), Bash(checkupdates), Bash(fwupdmgr get-updates:*), Bash(uname:*), Bash(df:*), Bash(free:*), Bash(ss:*)
---

# /audit

Audit window: `$ARGUMENTS`, or `-7d` if empty. Call it `SINCE` below.

**Read-only.** Fix nothing, and don't ask to during the audit. There is no passwordless sudo: list root-only checks at the end as `! <command>` for the user to run.

`logdrain` is often not on the tool PATH; use `~/.cargo/bin/logdrain`.

## 0. Context first

- Read memory for items already diagnosed or accepted (e.g. PSI IO inflated by Ghostty's io_uring). Report them as *known*, not as new findings, unless they got worse.
- `journalctl --list-boots | head -3`: journald is capped at 50M, so the window may be shorter than `SINCE`. Say so if it is.

## 1. Hard failures

- `systemctl --failed`; `systemctl --user --failed`
- `coredumpctl list --since SINCE`
- Unclean shutdowns: for each boot in the window, `journalctl -b <idx> -n 15 -o short-monotonic`. A clean one ends `Reached target System Reboot`/`System Power Off` … `Journal stopped`; anything else is a crash or power loss.
- `journalctl -k -p 3 --since SINCE`: filesystem, NVMe, MCE and GPU errors go straight to tier 1.
- Pending reboot: `uname -r` vs `pacman -Q linux-cachyos`, and `head -1 /proc/driver/nvidia/version` vs `pacman -Q nvidia-utils`. A mismatch is a reboot owed; `NVRM: API mismatch` in the journal is the same thing seen from the logs.

## 2. Journal patterns (logdrain)

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

## 3. System state

- Boot: `systemd-analyze`; `systemd-analyze blame | head -15`
- Timers: `systemctl list-timers --all`; `systemctl --user list-timers --all`. Look for `n/a` last runs.
- Packages: `pacdiff -o`; `checkupdates`; `grep -iE 'warning|error' /var/log/pacman.log | tail -40`; `pacman -Qdtq`
- Firmware: `fwupdmgr get-updates`
- Hardware: `sensors`; `cat /proc/pressure/{cpu,memory,io}`; `df -h / /home /boot`; `free -h`; `journalctl --disk-usage`
- Exposure: `systemctl is-active ufw`; `ss -tulpn` for listeners not bound to loopback
- Cruft: `find /var/log -maxdepth 1 -mtime +90`

## 4. Rank

Tiers, top to bottom:

1. **Critical**: risk of data loss, hardware fault, security exposure, crashes, unclean shutdowns.
2. **Broken**: something the user relies on doesn't work (failed unit, driver/API mismatch, audio or Bluetooth errors).
3. **Degraded / pending**: reboot pending, unmerged `.pacnew` with real changes, updates, slow boot, performance.
4. **Noise**: no visible effect. Worth fixing only when cheap, since silencing it keeps future audits readable.

Within a tier, rank higher when the issue is still happening, frequent, and cheap to fix.

Name where the cause lives (package, `/etc` file, a dotfiles path, firmware, hardware) and mark it *likely* unless you verified it. Don't prescribe a fix wider than the diagnosed cause.

## Output

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
