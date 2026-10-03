#!/usr/bin/env python3
# Print the /uses page, read from this repo, as Markdown.
#   uses/uses.py | pandoc -d uses/pandoc.yaml -o index.html
# ruff: noqa: INP001, E731
# pyright: reportUnusedExpression=false

from sys import stdout
import json
from pathlib import Path


ROOT_DIR = Path(__file__).resolve().parents[1]


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
h2 = lambda text: Text(f"\n## {text}")
h3 = lambda text: Text(f"\n### {text}")
li = lambda text: Text(f"- {text}")
tr = lambda *cells: Text(f"| {' | '.join(cells)} |")
th = lambda *cells: Text(f"\n{tr(*cells)}\n|{'---|' * len(cells)}")


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
