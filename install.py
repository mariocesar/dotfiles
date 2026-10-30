#!/usr/bin/env python3
# Symlink home/common and this OS's bucket into $HOME, then run their postinstall hooks.

import re
import sys
import argparse
import os
from pathlib import Path
import subprocess


ROOT_DIR = Path(__file__).parent.resolve()
BUCKETS_DIR = ROOT_DIR / "home"
HOOKS_DIR = ROOT_DIR / "postinstall"
HOME_DIR = Path.home()
PLATFORM = "macos" if sys.platform == "darwin" else "linux"
# Shared first, platform second: a path in both is deliberately won by the platform.
ACTIVE_BUCKETS = ("common", PLATFORM)
FOREIGN_BUCKET = "linux" if PLATFORM == "macos" else "macos"


def puts(message: str) -> None:
    for pattern, color in ((r"-- .*? --", "1;37"), (r"~?/\S*", "36"), (r"\[.*?\]", "1;33")):
        message = re.sub(pattern, f"\033[{color}m\\g<0>\033[0m", message)
    print(message, flush=True)


def act(message: str, *, fake: bool) -> bool:
    """Announce a change; False under --fake, so the caller skips making it."""
    puts(f"[FAKE] {message}" if fake else message)
    return not fake


def bucket_files(bucket: str) -> list[str]:
    # What git tracks or would track, so ignored junk (.DS_Store, *~) never gets linked.
    listing = subprocess.run(
        ["git", "ls-files", "-zco", "--exclude-standard"],  # noqa: S607
        cwd=BUCKETS_DIR / bucket,
        capture_output=True,
        text=True,
        check=True,
    ).stdout
    # -c still lists a file deleted from the worktree until the deletion is staged.
    return [name for name in listing.split("\0") if name and (BUCKETS_DIR / bucket / name).exists()]


def link_active_buckets(*, force: bool, fake: bool) -> dict[Path, str]:  # noqa: C901, PLR0912
    """Returns which bucket owns each linked dest."""
    owner: dict[Path, str] = {}
    announced_dirs: set[Path] = set()

    for bucket in ACTIVE_BUCKETS:
        for name in bucket_files(bucket):
            source, dest = BUCKETS_DIR / bucket / name, HOME_DIR / name
            if dest in owner:
                puts(f"-- {dest} from {owner[dest]} overridden by {bucket} --")
            owner[dest] = bucket

            # --fake never creates the directory, so remember it to announce it once.
            if dest.parent not in announced_dirs and not dest.parent.exists():
                announced_dirs.add(dest.parent)
                if act(f"Creating directory {dest.parent}", fake=fake):
                    dest.parent.mkdir(parents=True)

            if dest.is_symlink() and dest.resolve() == source:
                puts(f"Symlink already points to {source}")
            elif dest.is_symlink():
                if act(f"Updating link {dest} to {source}", fake=fake):
                    dest.unlink()
                    dest.symlink_to(source)
            elif dest.exists() and not force:
                puts(f"Destination exists: {dest}")
            elif dest.exists():
                backup, count = dest.with_name(f"{dest.name}.bak"), 1
                while backup.is_symlink() or backup.exists():
                    backup, count = dest.with_name(f"{dest.name}.bak.{count}"), count + 1
                if act(f"Moving {dest} to {backup}, linking to {source}", fake=fake):
                    dest.rename(backup)
                    dest.symlink_to(source)
            elif act(f"Linking {source} to {dest}", fake=fake):
                dest.symlink_to(source)

    return owner


def skip_foreign_bucket(installed: dict[Path, str], *, prune: bool, fake: bool) -> None:
    """Under prune, also unlink what an earlier install left of the other OS's bucket."""
    skipped = 0

    for name in bucket_files(FOREIGN_BUCKET):
        dest = HOME_DIR / name
        # A name shared across platform buckets is installed, not foreign.
        if dest in installed:
            continue
        skipped += 1
        if fake:
            puts(f"Skipping {FOREIGN_BUCKET}-only {dest}")

        # resolve() follows the link even when it dangles, which a moved file's old link does.
        if not prune or not dest.is_symlink() or not dest.resolve().is_relative_to(ROOT_DIR):
            continue
        if act(f"Pruning {dest}", fake=fake):
            dest.unlink()
            directory = dest.parent
            while directory != HOME_DIR and not any(directory.iterdir()):
                puts(f"Removing empty {directory}")
                directory.rmdir()
                directory = directory.parent

    if skipped:
        puts(f"-- Skipped {skipped} {FOREIGN_BUCKET}-only files, this is {PLATFORM} --")


def run_hooks(*, fake: bool) -> int:
    """Returns how many hooks failed."""
    # Keyed by name, so a platform hook replaces a same-named common one.
    hooks = {
        hook.name: hook for bucket in ACTIVE_BUCKETS for hook in (HOOKS_DIR / bucket).glob("*")
    }
    failed = 0

    for _, hook in sorted(hooks.items()):
        if not os.access(hook, os.X_OK):
            continue
        if not act(f"-- Running {hook.relative_to(ROOT_DIR)} --", fake=fake):
            continue
        # .py hooks reuse this interpreter so they don't depend on the system python3 version.
        command = [sys.executable, str(hook)] if hook.suffix == ".py" else [str(hook)]
        env = {**os.environ, "DOTFILES_ROOT": str(ROOT_DIR)}
        returncode = subprocess.run(command, cwd=ROOT_DIR, env=env, check=False).returncode  # noqa: S603
        if returncode:
            puts(f"[FAILED] {hook} exited with {returncode}")
            failed += 1

    return failed


def main() -> int:
    parser = argparse.ArgumentParser(description="Install dotfiles")
    parser.add_argument(
        "--force", action="store_true", help="Replace existing files, keeping the original as .bak"
    )
    parser.add_argument(
        "--fake", action="store_true", help="Simulate actions without making changes"
    )
    parser.add_argument(
        "--prune",
        action="store_true",
        help="Also remove links for config belonging to the other OS",
    )
    options = parser.parse_args()

    puts("-- Starting dotfiles installation --")
    installed = link_active_buckets(force=options.force, fake=options.fake)
    skip_foreign_bucket(installed, prune=options.prune, fake=options.fake)
    failed = run_hooks(fake=options.fake)
    puts(f"-- Finished, {failed} hook(s) failed --" if failed else "-- Finished --")
    return 1 if failed else 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        puts("\n\n-- Stop --")
        sys.exit(1)
