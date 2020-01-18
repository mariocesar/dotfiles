#!/usr/bin/env python3
import argparse
import glob
import re
import os
from pathlib import Path
from itertools import chain

ROOT_DIR = Path(__file__).parent.resolve()
HOME_DIR = Path.home()

print(ROOT_DIR, HOME_DIR)

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


def walk(path: Path):
    for item in path.glob("*"):
        if skip(item):
            continue

        if item.is_dir():
            yield from walk(item)
        else:
            yield item


dotfiles = walk(ROOT_DIR)


def main(options):
    for path in dotfiles:
        path = (ROOT_DIR / (path.relative_to(ROOT_DIR))).resolve()
        dest = (HOME_DIR / (path.relative_to(ROOT_DIR))).resolve()

        print(f"{dest.relative_to(HOME_DIR)} ", end="", flush=True)

        if options.force and dest.is_file():
            dest.unlink()
            print(f"[Force]", end=" ", flush=True)

        if dest.parent != ROOT_DIR:
            if not dest.parent.exists():
                dest.parent.mkdir(parents=True)

        if dest.exists():
            print(f"[Ok]")
        else:
            dest.symlink_to(path)
            print(f"[Installed]")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Install dotfiles")
    parser.add_argument(
        "--force",
        action="store_true",
        default=False,
        help="If target file exists it replaces it",
    )

    options = parser.parse_args()

    main(options)
