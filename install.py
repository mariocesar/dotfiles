#!/usr/bin/env python3
import re
import sys
import argparse
from collections.abc import Callable, Generator
from pathlib import Path


ROOT_DIR = Path(__file__).parent.resolve()
HOME_DIR = Path.home()


EXCLUDE_PATTERNS = [
    re.compile(r".*\.DS_Store").match,
    re.compile(r"^\.git/").match,
    re.compile(r"^\.vscode$").match,
    re.compile(r"^\.gitignore$").match,
    re.compile(r"\.pyc$").match,
    re.compile(r"~$").match,
    re.compile(r"ruff\.toml").match,
    re.compile(r"README\.md").match,
    re.compile(r"install\.py").match,
]


class Installer:
    def __init__(self, *, force: bool, interactive: bool, fake: bool) -> None:
        self.force = force
        self.interactive = interactive
        self.fake = fake

    def confirm(self, message: str) -> bool:
        """Prompt for confirmation if interactive mode is enabled."""
        return not self.interactive or input(message).lower() == "y"

    def should_skip(self, path: Path) -> bool:
        """Check if a file should be skipped based on exclude patterns."""
        return any(match(str(path.relative_to(ROOT_DIR))) for match in EXCLUDE_PATTERNS)

    def list_dotfiles(self, path: Path) -> Generator[Path, None, None]:
        """Generate a list of dotfiles to be installed, skipping excluded ones."""
        for item in path.glob("*"):
            if self.should_skip(item):
                continue

            if item.is_dir():
                yield from self.list_dotfiles(item)
            else:
                yield item

    def run(self) -> None:
        for path in self.list_dotfiles(ROOT_DIR):
            source = ROOT_DIR / path.relative_to(ROOT_DIR)
            dest = HOME_DIR / path.relative_to(ROOT_DIR)

            if self.force and dest.is_file():
                self.handle_file_removal(dest)

            self.create_directory_if_not_exists(dest.parent)
            self.create_or_update_symlink(source, dest)

    def handle_file_removal(self, dest: Path):
        if self.confirm(f"Delete {dest} before installing? (Y/n): "):
            self.perform_action(f"Removing {dest}", lambda: dest.unlink())

    def create_directory_if_not_exists(self, directory: Path):
        if not directory.exists():
            self.perform_action(
                f"Creating directory {directory}", lambda: directory.mkdir(parents=True)
            )

    def create_or_update_symlink(self, source: Path, dest: Path):
        if not dest.exists() and self.confirm(f"Create the symlink {dest}? (Y/n): "):
            self.perform_action(f"Linking {source} to {dest}", lambda: dest.symlink_to(source))
        else:
            self.perform_action(f"Destination exists: {dest}", lambda: dest.touch())

    def perform_action(self, message: str, action: Callable):
        print(f"{'[DRY RUN] ' if self.fake else ''}{message}")

        if not self.fake:
            action()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Install dotfiles")
    parser.add_argument("--noinput", action="store_false", help="Run without interactive prompts")
    parser.add_argument("--force", action="store_true", help="Replace existing files")
    parser.add_argument(
        "--fake", action="store_true", help="Simulate actions without making changes"
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
