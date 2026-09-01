#!/usr/bin/env python3

import os
import re
import sys
import argparse
import subprocess
from collections.abc import Callable, Generator
from functools import partial
from pathlib import Path


ROOT_DIR = Path(__file__).parent.resolve()
HOME_DIR = Path.home()
HOOKS_DIR = ROOT_DIR / "postinstall.d"


class DotfileMapper:
    EXCLUDE_PATTERNS: list[re.Pattern] = [
        re.compile(pattern)
        for pattern in (
            r".*\.DS_Store$",
            r"^.+\.py[co]$",
            r"^.+\~$",
            r"^\.git$",
            r"^\.vscode$",
            r"^\..*_cache$",
            r"^Brewfile$",
            r"^Brewfile\.lock\.json$",
            r"^\.gitignore$",
            r"^ruff\.toml$",
            r"^pyproject\.toml$",
            r"^uv\.lock$",
            r"^\.python-version$",
            r"^\.envrc$",
            r"^\.venv$",
            r"^README\.md$",
            r"^CLAUDE\.md$",
            r"^LICENSE$",
            r"^install\.py$",
            r"^pkglist",
            r"^postinstall\.d$",
        )
    ]

    def __init__(self, workdir: Path, target: Path):
        self.workdir = workdir
        self.target = target
        self.exclude_pattern = re.compile(
            r"|".join(pattern.pattern for pattern in self.EXCLUDE_PATTERNS)
        )

    def __call__(self) -> Generator[tuple[Path, Path], None, None]:
        """Generate a list of dotfiles to be installed, skipping excluded ones."""
        for item in self.walk():
            rel_path = item.relative_to(self.workdir)
            source = self.workdir / rel_path
            dest = self.target / rel_path
            yield source, dest

    def walk(self, basedir: Path | None = None) -> Generator[Path, None, None]:
        basedir = basedir or self.workdir

        for item in basedir.glob("*"):
            rel_path = str(Path(item).relative_to(self.workdir))

            if self.exclude_pattern.match(rel_path):
                continue

            if item.is_dir():
                yield from self.walk(item)
            else:
                yield item


list_dotfiles = DotfileMapper(ROOT_DIR, HOME_DIR)


def confirm(prompt: str, *, default: bool = True, interactive: bool = True) -> bool:
    """Prompt the user for confirmation."""
    if not interactive:
        return default

    suffix = " (Y/n): " if default else " (y/N): "
    response = input(prompt + suffix).strip().lower()
    return default if not response else response[0] == "y"


def backup_path(dest: Path) -> Path:
    backup = dest.with_name(dest.name + ".bak")
    count = 1

    while backup.is_symlink() or backup.exists():
        backup = dest.with_name(f"{dest.name}.bak.{count}")
        count += 1

    return backup


def puts(message: str) -> None:
    color_reset = "\033[0m"
    color_cyan = "\033[36m"
    color_bold_white = "\033[1;37m"
    color_bold_orange = "\033[1;33m"

    def apply_color(match: re.Match, color: str) -> str:
        return f"{color}{match.group(0)}{color_reset}"

    apply_tag_format = partial(apply_color, color=color_bold_white)
    apply_path_format = partial(apply_color, color=color_cyan)
    apply_event_format = partial(apply_color, color=color_bold_orange)

    formatted = re.sub(r"-- (.*?) --", apply_tag_format, message)
    formatted = re.sub(r"((?:/|~/)[^\s]*)", apply_path_format, formatted)
    formatted = re.sub(r"\[(.*?)\]", apply_event_format, formatted)

    print(formatted, flush=True)


class Installer:
    def __init__(self, *, force: bool, interactive: bool, fake: bool) -> None:
        self.force = force
        self.fake = fake
        self.confirm = partial(confirm, interactive=interactive)
        self._created_dirs = set()

    def run(self) -> int:
        for source, dest in list_dotfiles():
            self.create_directory_if_not_exists(dest.parent)
            self.install(source, dest)

        return self.run_hooks()

    def run_hooks(self) -> int:
        """Run every executable in postinstall.d in name order; returns the failure count."""
        failed = 0

        for hook in sorted(HOOKS_DIR.glob("*")):
            if not os.access(hook, os.X_OK):
                continue

            puts(f"-- Running {hook.relative_to(ROOT_DIR)} --")

            if self.fake:
                puts(f"[FAKE] Would run {hook}")
                continue

            # .py hooks reuse this interpreter so they don't depend on the system python3 version.
            command = [sys.executable, str(hook)] if hook.suffix == ".py" else [str(hook)]
            result = subprocess.run(
                command,
                cwd=ROOT_DIR,
                env={**os.environ, "DOTFILES_ROOT": str(ROOT_DIR)},
            )

            if result.returncode:
                puts(f"[FAILED] {hook} exited with {result.returncode}")
                failed += 1

        return failed

    def handle_file_removal(self, dest: Path):
        if self.confirm(f"Delete {dest} before installing? (Y/n)"):
            self.perform_action(f"Removing {dest}", lambda: dest.unlink())

    def create_directory_if_not_exists(self, directory: Path):
        if str(directory) in self._created_dirs:
            return

        if not directory.exists():
            self.perform_action(
                f"Creating directory {directory}",
                lambda: directory.mkdir(parents=True),
            )

        self._created_dirs.add(str(directory))

    def install(self, source: Path, dest: Path):
        if dest.is_symlink() or dest.exists():
            if dest.is_symlink():
                if dest.resolve() == source:
                    return self.perform_action(f"Symlink already points to {source}", lambda: None)

                if self.confirm(f"Update the symlink {dest} to point to {source}?"):
                    return self.perform_action(
                        f"Updating link {dest} to {source}",
                        lambda: (dest.unlink(), dest.symlink_to(source)),
                    )

                return self.perform_action(
                    f"Keeping {dest} pointing to {dest.readlink()}", lambda: None
                )

            if self.force and self.confirm(f"Replace {dest} with a symlink to {source}?"):
                backup = backup_path(dest)
                return self.perform_action(
                    f"Moving {dest} to {backup}, linking to {source}",
                    lambda: (dest.rename(backup), dest.symlink_to(source)),
                )

            return self.perform_action(f"Destination exists: {dest}", lambda: None)

        if not self.confirm(f"Create the symlink {dest}?"):
            return None

        return self.perform_action(
            f"Linking {source} to {dest}",
            lambda: dest.symlink_to(source),
        )

    def perform_action(self, message: str, action: Callable) -> None:
        puts(f"{'[FAKE] ' if self.fake else ''}{message}")

        if not self.fake:
            action()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Install dotfiles")
    parser.add_argument(
        "--interactive",
        action="store_true",
        default=False,
        help="Run with interactive prompts",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Replace existing files, keeping the original as .bak",
    )
    parser.add_argument(
        "--fake",
        action="store_true",
        help="Simulate actions without making changes",
    )

    options = parser.parse_args()

    puts("-- Starting dotfiles installation --")

    try:
        failed = Installer(
            force=options.force,
            interactive=options.interactive,
            fake=options.fake,
        ).run()
    except KeyboardInterrupt:
        puts("\n\n-- Stop --")
        sys.exit(1)
    else:
        puts("-- Finished --" if not failed else f"-- Finished, {failed} hook(s) failed --")
        sys.exit(1 if failed else 0)
