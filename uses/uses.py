#!/usr/bin/env python3
# Print the /uses page, read from this repo, as Markdown.
#   uses/uses.py | pandoc -d uses/pandoc.yaml -o index.html
# ruff: noqa: INP001, E731
# pyright: reportUnusedExpression=false

import re
from sys import stdout
import json
from pathlib import Path


ROOT_DIR = Path(__file__).resolve().parents[1]
REPO = "https://github.com/mariocesar/dotfiles"


class Text(str):
    # + joins words with a space, >> prints to a stream.
    def __add__(self, other):
        return Text(f"{self} {other}")

    def __radd__(self, other):
        return Text(f"{other} {self}")

    def __rshift__(self, stream):
        print(self, file=stream)


b = lambda text: Text(f"**{text}**")
i = lambda text: Text(f"*{text}*")
a = lambda text, href: Text(f"[{text}]({href})")
p = lambda text: Text(f"\n{text}")
h2 = lambda text: Text(f"\n## {text}")
h3 = lambda text: Text(f"\n### {text}")
li = lambda text: Text(f"- {text}")
code = lambda text: Text(f"`{text}`")
tr = lambda *cells: Text(f"| {' | '.join(cells)} |")
th = lambda *cells: Text(f"\n{tr(*cells)}\n|{'---|' * len(cells)}")

nl = lambda: Text() >> stdout
hr = lambda: Text("\n---") >> stdout


h2("Machines") >> stdout

for path in sorted((ROOT_DIR / "machines").glob("*.json")):
    manifest = json.loads(path.read_text())
    host, board, cpu = manifest["host"], manifest["board"], manifest["cpu"]

    th(manifest["name"], host["chassis"]) >> stdout
    tr("os", manifest["os"]) >> stdout

    # On a desktop fastfetch reports the board as the host model.
    if host["model"] == board["model"]:
        tr("board", f"{board['vendor']} {board['model']}") >> stdout
    else:
        tr("model", host["model"]) >> stdout

    cores = f"{cpu['cores']} cores"
    if "threads" in cpu:
        cores += f", {cpu['threads']} threads"
    model = cpu["model"].replace("(R)", "").replace("(TM)", "")

    tr("cpu", f"{model} · {cores}") >> stdout

    for gpu in manifest["gpus"]:
        name = gpu["model"]
        if not name.startswith(gpu["vendor"]):
            name = f"{gpu['vendor']} {name}"
        if "cores" in gpu:
            name += f" · {gpu['cores']} cores"
        tr("gpu", name) >> stdout

    tr("ram", f"{manifest['memory_gib']} GB") >> stdout

    for d in manifest["displays"]:
        # The Mac's own panel is named "Color LCD".
        name = "Built-in" if d["type"] == "Builtin" else d["model"]
        size = f"{d['width']}×{d['height']} @ {d['refresh_hz']} Hz"
        tr("display", f"{name} · {size}") >> stdout


h2("My ~/.local/bin scripts") >> stdout

niri = (ROOT_DIR / "linux/.config/niri/config.kdl").read_text().splitlines()
units = ROOT_DIR / "linux/.config/systemd/user"
launchers = ROOT_DIR / "linux/.local/share/applications"

# Each tag with the config text that runs a script that way.
wiring = {
    "keybind": "\n".join(line for line in niri if not line.startswith("spawn-at-startup")),
    "startup": "\n".join(line for line in niri if line.startswith("spawn-at-startup")),
    "timer": "".join(path.with_suffix(".service").read_text() for path in units.glob("*.timer")),
    "launcher": "\n".join(
        line
        for path in launchers.glob("*.desktop")
        for line in path.read_text().splitlines()
        if line.startswith("Exec=")
    ),
}

for bucket, title in ("common", "common"), ("linux", "only linux"), ("macos", "only macos"):
    th(title, "", "") >> stdout

    for path in sorted((ROOT_DIR / bucket / ".local/bin").iterdir()):
        shebang, about, *_ = path.read_text().splitlines()

        # No sentence on line 2, not listed.
        if not about.startswith("# "):
            continue
        if "uv run" in shebang:
            tags = code("python") + code("uv")
        else:
            tags = code(next(name for name in ("python", "bash", "sh") if name in shebang))

        if path.name.startswith("git-"):
            tags += code("git")

        # As a path or a bare command, and not as the start of a longer name.
        runs = re.compile(rf"[/=]{re.escape(path.name)}(?![\w-])")
        for tag, text in wiring.items():
            if runs.search(text):
                tags += code(tag)

        (
            tr(
                a(path.name, f"{REPO}/blob/main/{path.relative_to(ROOT_DIR)}"),
                about[2:],
                tags,
            )
            >> stdout
        )

nl()

li(code("sh") + code("bash") + code("python") + "the language it is written in") >> stdout
li(code("uv") + "run by uv, which fetches its dependencies") >> stdout
li(code("git") + "a git subcommand: git-watch runs as git watch") >> stdout
li(code("keybind") + "bound to a key in niri") >> stdout
li(code("startup") + "started with the niri session") >> stdout
li(code("timer") + "run by a systemd timer") >> stdout
li(code("launcher") + "has an entry in the app launcher") >> stdout

hr()

p("❤️ Generated with" + a(f"{REPO}/uses/", f"{REPO}/tree/main/uses")) >> stdout
