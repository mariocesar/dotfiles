import re
import sys
import argparse
from collections.abc import Callable, Generator
from functools import partial
from pathlib import Path


ROOT_DIR = Path(__file__).parent.resolve()
HOME_DIR = Path.home()


class DotfileMapper:
    EXCLUDE_PATTERNS: list[re.Pattern] = list(
        map(
            re.compile,
            (
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
            ),
        ),
    )

    def __init__(self, workdir: Path, target: Path):
        self.workdir = workdir
        self.target = target

    def __call__(self) -> Generator[tuple[Path, Path], None, None]:
        """Generate a list of dotfiles to be installed, skipping excluded ones."""
        for item in self.walk():
            source = self.workdir / item.relative_to(self.workdir)
            dest = self.target / item.relative_to(self.workdir)

            yield source, dest

    def walk(self, basedir: Path | None = None) -> Generator[Path, None, None]:
        basedir = basedir or self.workdir

        for item in basedir.glob("*"):
            rel_path = str(Path(item).relative_to(self.workdir))

            if any(pattern.match(rel_path) for pattern in self.EXCLUDE_PATTERNS):
                continue

            if item.is_dir():
                yield from self.walk(item)
            else:
                yield item


list_dotfiles = DotfileMapper(ROOT_DIR, HOME_DIR)


def confirm(prompt: str, *, default: bool = True, fake: bool = False) -> bool:
    """Prompt the user for confirmation."""
    if fake:
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
        self.interactive = interactive
        self.fake = fake

    def run(self) -> None:
        for source, dest in list_dotfiles():
            if self.force and dest.is_file():
                self.handle_file_removal(dest)

            self.create_directory_if_not_exists(dest.parent)
            self.create_or_update_symlink(source, dest)

    def handle_file_removal(self, dest: Path):
        if confirm(f"Delete {dest} before installing? (Y/n)", fake=self.interactive):
            self.perform_action(f"Removing {dest}", lambda: dest.unlink())

    def create_directory_if_not_exists(self, directory: Path):
        if not directory.exists():
            self.perform_action(
                f"Creating directory {directory}", lambda: directory.mkdir(parents=True)
            )

    def create_or_update_symlink(self, source: Path, dest: Path):
        if not dest.exists() and confirm(f"Create the symlink {dest}?", fake=self.interactive):
            self.perform_action(f"Linking {source} to {dest}", lambda: dest.symlink_to(source))
        else:
            self.perform_action(f"Destination exists: {dest}", lambda: dest.touch())

    def perform_action(self, message: str, action: Callable):
        puts(f"{'[FAKE] ' if self.fake else ''}{message}")

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

    puts("-- Starting dotfiles installation --")

    try:
        Installer(
            force=options.force,
            interactive=not options.noinput,
            fake=options.fake,
        ).run()
    except KeyboardInterrupt:
        puts("\n\n-- Stop --")
        sys.exit(1)
    else:
        puts("-- Finished --")
        sys.exit(0)
