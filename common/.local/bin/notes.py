#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.12"
# ///
# ruff: noqa: INP001
"""Resolve a notebook path from context. Principles and aliases: ~/.config/zsh/zshnotes.zsh."""

import re
import sys
import argparse
import datetime as dt
import os
from pathlib import Path
import shutil
import subprocess
import unicodedata


HOME = Path.home()
LIBRARY = HOME / ".notes"
NAME = re.compile(r"[A-Za-z0-9][A-Za-z0-9._-]*")


def fail(message):
    print(f"notes: {message}", file=sys.stderr)
    sys.exit(1)


def logical_cwd():
    # Path.cwd() is physical; $PWD is the shell's view, trusted while it still points here
    pwd = os.environ.get("PWD", "")
    try:
        if pwd and Path(pwd).samefile("."):
            return Path(os.path.normpath(pwd))
    except OSError:
        pass
    return Path.cwd()


def home_notebook():
    cwd = logical_cwd()
    if cwd.is_relative_to(LIBRARY):
        return cwd  # a directory inside the library is its own notebook, never mirrored again
    container = cwd
    git = shutil.which("git")
    proc = None
    if git:
        proc = subprocess.run(  # noqa: S603
            [git, "rev-parse", "--show-prefix", "--show-toplevel"],
            capture_output=True,
            text=True,
            check=False,
        )
    if proc and proc.returncode == 0:
        prefix, toplevel = proc.stdout.splitlines()
        parts = Path(prefix).parts
        if parts and cwd.parts[-len(parts) :] == parts:
            container = Path(*cwd.parts[: -len(parts)])  # strip git's physical prefix lexically
        elif parts:
            container = Path(toplevel)  # cwd reached through a symlink inside the repo
    try:
        rel = container.relative_to(HOME)
    except ValueError:
        fail(f"{container} is outside $HOME")
    return LIBRARY / "home" / rel


def named_notebook(name):
    if not NAME.fullmatch(name):
        fail(f"invalid notebook name {name!r}")
    return LIBRARY / "named" / name


def slug(title):
    # ASCII only: macOS and Linux normalize accented filenames differently
    folded = unicodedata.normalize("NFKD", title).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "-", folded.lower()).strip("-")


DESCRIPTION = """\
Resolve a notebook and print a path inside it. Notes are plain Markdown files.

  ~/.notes/home/<path>   the git root (else cwd) relative to $HOME; the default
  ~/.notes/named/NAME    an explicit notebook, with -n NAME
"""

EPILOG = """\
zsh shortcuts (~/.config/zsh/zshnotes.zsh):
  n [-n NAME]        edit the notebook's notes.md
  nn [TITLE...]      edit a new note
  nj                 edit today's journal entry
  nb [-n NAME]       browse the notebook in glow
  ns PATTERN         search the notebook
  nsa PATTERN        search the whole library
  nf [-n NAME]       pick a note with fzf and edit it
  ncd [-n NAME]      cd into the notebook
  the editor is nvim-autosave: nvim whose buffers write themselves

with other tools:
  nvim "$(notes file)"                    edit the persistent note
  nvim "$(notes new 'postgres locking')"  create and edit a titled note
  nvim "$(notes -n journal today)"        today's journal entry
  glow -a "$(notes)"                      browse the notebook
  rg --hidden postgres "$(notes)"         search the notebook
  rg --hidden postgres ~/.notes           search everything
  fd -H -e md . "$(notes)" | fzf          pick a note
  cd "$(notes)"

Mirrored dot-dirs (home/.ssh) are hidden: pass --hidden to rg, -H to fd, -a to glow.
"""


def main():
    parser = argparse.ArgumentParser(
        prog="notes",
        description=DESCRIPTION,
        epilog=EPILOG,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("-n", "--name", help="a named notebook instead of the one for cwd")
    commands = parser.add_subparsers(dest="command")
    commands.add_parser("path", help="the notebook directory (default)")
    commands.add_parser("file", help="the notebook's notes.md")
    new = commands.add_parser("new", help="a new timestamped note")
    new.add_argument("title", nargs="*", help="words for the filename, after the timestamp")
    commands.add_parser("today", help="today's note, as YYYY/MM/YYYY-MM-DD.md")
    args = parser.parse_args()

    notebook = named_notebook(args.name) if args.name else home_notebook()
    notebook.mkdir(parents=True, exist_ok=True)
    now = dt.datetime.now()

    match args.command:
        case "file":
            target = notebook / "notes.md"
        case "new":
            stamp = f"{now:%Y-%m-%d-%H%M%S}"
            title = slug(" ".join(args.title))
            target = notebook / (f"{stamp}-{title}.md" if title else f"{stamp}.md")
        case "today":
            target = notebook / f"{now:%Y}/{now:%m}/{now:%Y-%m-%d}.md"
            target.parent.mkdir(parents=True, exist_ok=True)
        case _:
            print(notebook)
            return
    target.touch()
    print(target)


if __name__ == "__main__":
    main()
