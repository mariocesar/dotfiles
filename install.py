#!/usr/bin/env python3
import argparse
import glob
import re
import os
import sys
from pathlib import Path
from itertools import chain

ROOT_DIR = Path(__file__).parent.resolve()
HOME_DIR = Path.home()

os.chdir(ROOT_DIR.parent)

exclude_patterns = [
    re.compile(r"^\.git/").match,
    re.compile(r"^\.vscode$").match,
    re.compile(r"^\.gitignore$").match,
    re.compile(r"\.pyc$").match,
    re.compile(r"~$").match,
    re.compile(r"README\.md").match,
    re.compile(r"install\.py").match,
]

skip = lambda path: any(
    map(lambda match: match(str(path.relative_to(ROOT_DIR))), exclude_patterns)
)


def step(message, interactive=False):
    if interactive:
        said_yes = (input(message) or "n").lower().strip()[0] == "y"
        if said_yes:
            return True

    return False


def walk(path: Path):
    for item in path.glob("*"):
        if skip(item):
            continue

        if item.is_dir():
            yield from walk(item)
        else:
            yield item


def main(options):
    dotfiles = walk(ROOT_DIR)

    for path in dotfiles:
        source = ROOT_DIR / path.relative_to(ROOT_DIR)
        dest = HOME_DIR / path.relative_to(ROOT_DIR)

        print(f"~/{dest.relative_to(HOME_DIR)} ", end="", flush=True)

        if options.force and dest.is_file():
            if step(f"Delete {dest!s} before install it? (Y/n): ", options.interactive):
                dest.unlink()

            print(f"[Force]", end=" ", flush=True)

        if dest.parent != ROOT_DIR:
            if not dest.parent.exists():
                dest.parent.mkdir(parents=True)

        if dest.exists():
            print(f"[Ok]")
        else:
            if step(f"Create the symlink to {dest!s}? (Y/n): ", options.interactive):
                dest.symlink_to(source)

            print(f"[Done]")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Install dotfiles")
    parser.add_argument(
        "--interactive",
        action="store_true",
        default=False,
        help="Ask to confirm every action",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        default=False,
        help="If target file exists it replaces it",
    )

    options = parser.parse_args()
    try:
        main(options)
    except KeyboardInterrupt:
        print("-- Stop --")
        sys.exit(1)
