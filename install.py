#!/usr/bin/env -S uv run --quiet --script
# /// script
# dependencies = ["pathspec", "rich"]
# requires-python = ">=3.11"
# ///
# vim: set filetype=python :
import sys
import argparse
from collections.abc import Callable, Generator
from pathlib import Path

from pathspec import PathSpec
import rich
from rich.prompt import Confirm


ROOT_DIR = Path(__file__).parent.resolve()
HOME_DIR = Path.home()

EXCLUDE_RULES = """
.DS_Store
*.py[co]
*~

.git/
.vscode/
.*_cache/

Brewfile
Brewfile.lock.json

.gitignore
ruff.toml
README.md
install.py
"""

ignore_spec = PathSpec.from_lines(
    "gitwildmatch",
    EXCLUDE_RULES.splitlines(),
)


def list_dotfiles(path: Path) -> Generator[Path, None, None]:
    """Generate a list of dotfiles to be installed, skipping excluded ones."""
    for item in path.glob("*"):
        if ignore_spec.match_file(item):
            continue

        if item.is_dir():
            yield from list_dotfiles(item)
        else:
            yield item


class Installer:
    def __init__(self, *, force: bool, interactive: bool, fake: bool) -> None:
        self.force = force
        self.interactive = interactive
        self.fake = fake

    def run(self) -> None:
        for path in list_dotfiles(ROOT_DIR):
            source = ROOT_DIR / path.relative_to(ROOT_DIR)
            dest = HOME_DIR / path.relative_to(ROOT_DIR)

            if self.force and dest.is_file():
                self.handle_file_removal(dest)

            self.create_directory_if_not_exists(dest.parent)
            self.create_or_update_symlink(source, dest)

    def handle_file_removal(self, dest: Path):
        if Confirm.ask(f"Delete {dest} before installing? (Y/n)"):
            self.perform_action(f"Removing {dest}", lambda: dest.unlink())

    def create_directory_if_not_exists(self, directory: Path):
        if not directory.exists():
            self.perform_action(
                f"Creating directory {directory}", lambda: directory.mkdir(parents=True)
            )

    def create_or_update_symlink(self, source: Path, dest: Path):
        if not dest.exists() and Confirm.ask(f"Create the symlink {dest}? "):
            self.perform_action(f"Linking {source} to {dest}", lambda: dest.symlink_to(source))
        else:
            self.perform_action(f"Destination exists: {dest}", lambda: dest.touch())

    def perform_action(self, message: str, action: Callable):
        rich.print(f"{'[DRY RUN] ' if self.fake else ''}{message}")

        if not self.fake:
            action()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Install dotfiles")
    parser.add_argument(
        "--noinput",
        action="store_false",
        help="Run without interactive prompts",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Replace existing files",
    )
    parser.add_argument(
        "--fake",
        action="store_true",
        help="Simulate actions without making changes",
    )

    options = parser.parse_args()

    try:
        Installer(
            force=options.force,
            interactive=not options.noinput,
            fake=options.fake,
        ).run()
    except KeyboardInterrupt:
        print("\n\n-- Stop --")
        sys.exit(1)
