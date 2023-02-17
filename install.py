#!/usr/bin/env python3
import argparse
import os
import re
import sys
from pathlib import Path
from typing import Generator, Tuple

ROOT_DIR = Path(__file__).parent.resolve()
HOME_DIR = Path.home()

exclude_patterns = [
    re.compile(r"^\.git/").match,
    re.compile(r"^\.vscode$").match,
    re.compile(r"^\.gitignore$").match,
    re.compile(r"\.pyc$").match,
    re.compile(r"~$").match,
    re.compile(r"README\.md").match,
    re.compile(r"install\.py").match,
]


def skip(path: Path) -> bool:
    return any(
        map(lambda match: match(str(path.relative_to(ROOT_DIR))), exclude_patterns)
    )


def step(message: str, interactive: bool = False):
    if interactive:
        said_yes = (input(message) or "n").lower().strip()[0] == "y"
        if said_yes:
            return True
        else:
            return False

    return True


def walk(path: Path) -> Generator[Tuple[Path, Path], None, None]:
    for item in path.glob("*"):
        if skip(item):
            continue

        if item.is_dir():
            yield from walk(item)
        else:
            source = ROOT_DIR / item.relative_to(ROOT_DIR)
            dest = HOME_DIR / item.relative_to(ROOT_DIR)

            yield source, dest


def main(force: bool, interactive: bool, fake: bool) -> None:
    dotfiles = walk(ROOT_DIR)

    for source, dest in dotfiles:
        if force and dest.is_file():
            if step(f"Delete {dest!s} before install it? (Y/n): ", interactive):
                print(f"rm {dest}")

                if not fake:
                    dest.unlink()

        if dest.parent != ROOT_DIR:
            if not dest.parent.exists():
                print(f"mkdir -p {dest}")

                if not fake:
                    dest.parent.mkdir(parents=True)

        if dest.exists():
            print(f"touch {dest}")
            continue

        if step(f"Create the symlink to {dest!s}? (Y/n): ", interactive):
            print(f"ln -s {dest} {source}")

            if not fake:
                dest.symlink_to(source)


if __name__ == "__main__":
    os.chdir(ROOT_DIR.parent)

    parser = argparse.ArgumentParser(description="Install dotfiles")
    parser.add_argument(
        "--noinput",
        action="store_false",
        default=True,
        help="Don't ask to confirm every action",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        default=False,
        help="If target file exists it replaces it",
    )
    parser.add_argument(
        "--fake",
        action="store_true",
        default=False,
    )
    options = parser.parse_args()

    try:
        main(options.force, not options.noinput, options.fake)
    except KeyboardInterrupt:
        print("\n\n-- Stop --")
        sys.exit(1)
