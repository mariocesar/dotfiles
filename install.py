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
HOOKS_DIRNAME = "postinstall.d"
SHARED_BUCKET = "common"
PLATFORM_BUCKETS = ("linux", "macos")
PLATFORM = "macos" if sys.platform == "darwin" else "linux"
# Shared first, platform second: a path in both is deliberately won by the platform.
ACTIVE_BUCKETS = (SHARED_BUCKET, PLATFORM)


class DotfileMapper:
    # Only junk that can appear anywhere inside a bucket. Repo files sit outside every
    # bucket and are never walked, so none of them needs an entry here.
    EXCLUDE_PATTERNS = (
        r".*\.DS_Store$",
        r"^.+\.py[co]$",
        r"^.+\~$",
    )

    def __init__(self, workdir: Path, target: Path):
        self.workdir = workdir
        self.target = target
        self.hooks_dir = workdir / HOOKS_DIRNAME
        self.exclude = re.compile("|".join(self.EXCLUDE_PATTERNS))

    def __call__(self) -> Generator[tuple[Path, Path], None, None]:
        """Yield (source, dest) for every installable file in this bucket."""
        for item in self.walk():
            yield item, self.target / item.relative_to(self.workdir)

    def walk(self, basedir: Path | None = None) -> Generator[Path, None, None]:
        basedir = basedir or self.workdir

        for item in basedir.glob("*"):
            # postinstall.d is part of a bucket's shape: it gets run, never linked.
            if item == self.hooks_dir:
                continue

            if self.exclude.match(str(item.relative_to(self.workdir))):
                continue

            if item.is_dir():
                yield from self.walk(item)
            else:
                yield item


# Every bucket is walked identically; only which ones are active differs per machine.
BUCKETS = {
    name: DotfileMapper(ROOT_DIR / name, HOME_DIR) for name in (SHARED_BUCKET, *PLATFORM_BUCKETS)
}
ACTIVE = {name: BUCKETS[name] for name in ACTIVE_BUCKETS}
FOREIGN = {name: BUCKETS[name] for name in PLATFORM_BUCKETS if name != PLATFORM}


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
    def __init__(self, *, force: bool, interactive: bool, fake: bool, prune: bool) -> None:
        self.force = force
        self.fake = fake
        self.prune = prune
        self.confirm = partial(confirm, interactive=interactive)
        self._created_dirs = set()

    def run(self) -> int:
        installed = self.install_buckets()
        self.handle_foreign(installed)

        return self.run_hooks()

    def install_buckets(self) -> dict[Path, str]:
        """Link every active bucket; returns which bucket owns each dest."""
        owner: dict[Path, str] = {}

        for name, mapper in ACTIVE.items():
            for source, dest in mapper():
                # Shared runs first, so reaching a dest twice means the platform is winning.
                if dest in owner:
                    puts(f"-- {dest} from {owner[dest]} overridden by {name} --")

                owner[dest] = name
                self.create_directory_if_not_exists(dest.parent)
                self.install(source, dest)

        return owner

    def handle_foreign(self, installed: dict[Path, str]) -> None:
        """Buckets for the other OS: never linked here, and unlinked entirely under --prune."""
        for owner, mapper in FOREIGN.items():
            count = 0

            for _, dest in mapper():
                # A name shared across platform buckets (pkgsync) is installed, not foreign.
                if dest in installed:
                    continue

                count += 1

                if self.fake:
                    puts(f"Skipping {owner}-only {dest}")
                if self.prune:
                    self.prune_link(dest)

            if count:
                puts(f"-- Skipped {count} {owner}-only files, this is {PLATFORM} --")

    def prune_link(self, dest: Path) -> None:
        """Unlink what a platform-blind install left behind. Real files are left alone."""
        # resolve() follows the link even when it dangles, which a moved file's old link does.
        if not dest.is_symlink() or not dest.resolve().is_relative_to(ROOT_DIR):
            return

        self.perform_action(f"Pruning {dest}", dest.unlink)
        self.remove_empty_parents(dest.parent)

    def remove_empty_parents(self, directory: Path) -> None:
        """Pruning ~/.config/niri/config.kdl leaves the directory; walk up while they are empty."""
        if self.fake:  # nothing was unlinked, so emptiness cannot be judged
            return

        while directory != HOME_DIR and directory.is_relative_to(HOME_DIR):
            if not directory.is_dir() or any(directory.iterdir()):
                return

            self.perform_action(f"Removing empty {directory}", directory.rmdir)
            directory = directory.parent

    def run_hooks(self) -> int:
        """Run every executable in postinstall.d in name order; returns the failure count."""
        failed = 0

        # Keyed by name so a platform hook replaces a same-named common one, like the links;
        # sorted by name so hooks from both buckets interleave by their number prefix.
        hooks = {
            hook.name: hook for name in ACTIVE_BUCKETS for hook in BUCKETS[name].hooks_dir.glob("*")
        }

        for _, hook in sorted(hooks.items()):
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
    parser.add_argument(
        "--prune",
        action="store_true",
        help="Also remove links for config belonging to the other OS",
    )

    options = parser.parse_args()

    puts("-- Starting dotfiles installation --")

    try:
        failed = Installer(
            force=options.force,
            interactive=options.interactive,
            fake=options.fake,
            prune=options.prune,
        ).run()
    except KeyboardInterrupt:
        puts("\n\n-- Stop --")
        sys.exit(1)
    else:
        puts("-- Finished --" if not failed else f"-- Finished, {failed} hook(s) failed --")
        sys.exit(1 if failed else 0)
