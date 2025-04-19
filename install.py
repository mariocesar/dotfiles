import re
import sys
import argparse
from collections.abc import Callable, Generator
from functools import partial
from pathlib import Path


ROOT_DIR = Path(__file__).parent.resolve()
HOME_DIR = Path.home()


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
            r"^README\.md$",
            r"^LICENSE$",
            r"^install\.py$",
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
        return True

    suffix = " (Y/n): " if default else " (y/N): "
    response = input(prompt + suffix).strip().lower()
    return default if not response else response[0] == "y"


class Formatter:
    message_event_pattern = re.compile(r"-- (.*?) --")
    message_tag_pattern = re.compile(r"\[(.*?)\]")
    message_path_pattern = re.compile(r"((?:/|~/)[^\s]*)")

    color_reset = "\033[0m"
    color_cyan = "\033[36m"
    color_bold_white = "\033[1;37m"
    color_bold_orange = "\033[1;33m"

    @staticmethod
    def apply_color(match: re.Match, color: str) -> str:
        return f"{color}{match.group(0)}{Formatter.color_reset}"

    apply_tag_format = partial(apply_color, color=color_bold_white)
    apply_path_format = partial(apply_color, color=color_cyan)
    apply_event_format = partial(apply_color, color=color_bold_orange)

    def __call__(self, message: str) -> None:
        """Print text with color formatting."""
        # Format [*] patterns as bold white

        formatted = self.message_tag_pattern.sub(self.apply_tag_format, message)
        formatted = self.message_path_pattern.sub(self.apply_path_format, formatted)
        formatted = self.message_event_pattern.sub(self.apply_event_format, formatted)

        print(formatted)


puts = Formatter()


class Installer:
    def __init__(self, *, force: bool, interactive: bool, fake: bool) -> None:
        self.force = force
        self.fake = fake
        self.confirm = partial(confirm, interactive=interactive)
        self._created_dirs = set()

    def run(self) -> None:
        for source, dest in list_dotfiles():
            self.create_directory_if_not_exists(dest.parent)
            self.install(source, dest)

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
        if dest.exists():
            if dest.is_symlink() and dest.resolve() != source:
                if self.confirm(f"Update the symlink {dest} to point to {source}?"):
                    return self.perform_action(
                        f"Updating link {dest} to {source}",
                        lambda: (dest.unlink(), dest.symlink_to(source)),
                    )

                return self.perform_action(f"Symlink already points to {source}", lambda: None)

            if self.force and self.confirm(f"Replace {dest} with a symlink to {source}?"):
                return self.perform_action(
                    f"Replacing {dest} with a symlink to {source}",
                    lambda: (dest.unlink(), dest.symlink_to(source)),
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
        help="Replace existing files",
    )
    parser.add_argument(
        "--fake",
        action="store_true",
        help="Simulate actions without making changes",
    )

    options = parser.parse_args()

    puts("-- Starting dotfiles installation --")

    try:
        Installer(
            force=options.force,
            interactive=options.interactive,
            fake=options.fake,
        ).run()
    except KeyboardInterrupt:
        puts("\n\n-- Stop --")
        sys.exit(1)
    else:
        puts("-- Finished --")
        sys.exit(0)
