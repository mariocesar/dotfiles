#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "psutil>=7.2.2",
# ]
# ///
import argparse
import os

import psutil


parser = argparse.ArgumentParser()
parser.add_argument("--format", choices=("plain", "ansi", "tmux"), default="tmux")
args = parser.parse_args()

cpu = psutil.cpu_percent(interval=0.1)
mem = psutil.virtual_memory().percent
load = os.getloadavg()
cores = psutil.cpu_count() or 1


def fmt(icon, value, pressure):
    color = "red" if pressure >= 90 else "yellow" if pressure >= 75 else "green"

    codes = {
        "plain": ("", ""),
        "ansi": (f"\033[{dict(red=31, yellow=33, green=32)[color]}m", "\033[39m"),
        "tmux": (f"#[fg={color}]", "#[fg=default]"),
    }
    start, end = codes[args.format]
    return f"{start}{icon}{end}{value}"


print(
    fmt("⚙", f"{cpu:.0f}%", cpu),
    fmt("▦", f"{mem:.0f}%", mem),
    fmt("↑", " ".join(f"{x:.2f}" for x in load), load[0] / cores * 100),
)
