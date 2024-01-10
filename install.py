#!/usr/bin/env python3
import argparse
import os
import re
import sys
from pathlib import Path
from typing import Generator, Tuple

ROOT_DIR = Path(__file__).parent.resolve()
HOME_DIR = Path.home()

EXCLUDE_PATTERNS = [
    re.compile(r"^\.git/").match,
    re.compile(r"^\.vscode$").match,
    re.compile(r"^\.gitignore$").match,
    re.compile(r"\.pyc$").match,
    re.compile(r"~$").match,
    re.compile(r"README\.md").match,
    re.compile(r"install\.py").match,
]


class Installer:
    def __init__(self, force: bool, interactive: bool, fake: bool) -> None:
        self.force = force
        self.interactive = interactive
        self.fake = fake

    def confirm(self, message: str):
        if not self.interactive:
            return True

        said_yes = (input(message) or "n").lower().strip()[0] == "y"

        if said_yes:
            return True
        else:
            return False

    def list_dotfiles(self, path: Path) -> Generator[Tuple[Path, Path], None, None]:
        def skip(path: Path) -> bool:
            return any(
                map(
                    lambda match: match(str(path.relative_to(ROOT_DIR))),
                    EXCLUDE_PATTERNS,
                )
            )

        for item in path.glob("*"):
            if skip(item):
                continue

            if item.is_dir():
                yield from self.list_dotfiles(item)
            else:
                source = ROOT_DIR / item.relative_to(ROOT_DIR)
                dest = HOME_DIR / item.relative_to(ROOT_DIR)

                yield source, dest

    def run(self) -> None:
        dotfiles = self.list_dotfiles(ROOT_DIR)

        for source, dest in dotfiles:
            if self.force and dest.is_file():
                if self.confirm(f"Delete {dest!s} before install it? (Y/n): "):
                    print(f"rm {dest}")

                    if not self.fake:
                        dest.unlink()

            if dest.parent != ROOT_DIR:
                if not dest.parent.exists():
                    print(f"mkdir -p {dest.parent}")

                    if not self.fake:
                        dest.parent.mkdir(parents=True)

            if dest.exists():
                print(f"touch {dest}")
                continue

            if self.confirm(f"Create the symlink to {dest!s}? (Y/n): "):
                print(f"ln -s {dest} {source}")

                if not self.fake:
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
        Installer(options.force, not options.noinput, options.fake).run()
    except KeyboardInterrupt:
        print("\n\n-- Stop --")
        sys.exit(1)
