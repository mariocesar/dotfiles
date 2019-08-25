#!/usr/bin/env python3
import argparse
import glob
import re
import os
from pathlib import Path
from itertools import chain

root_dir = Path(__file__)
home_dir = Path(os.path.expanduser('~'))

os.chdir(root_dir.parent.resolve())

all_files = set(chain(
    glob.glob('.*/**', recursive=True),
    glob.glob('.*', recursive=True),
    glob.glob('*', recursive=True),
))

all_files = sorted(list(all_files))

exclude_patterns = [
    re.compile(r'^\.git/').match,
    re.compile(r'^\.dotfiles/').match,
    re.compile(r'^\.gitignore$').match,
    re.compile(r'^.*~$').match,
    re.compile(r'\.pyc$').match,
    re.compile(r'README\.md').match,
    re.compile(r'install\.py').match,
]

match_any = lambda path: any(map(lambda match: match(path), exclude_patterns))

filtered_files = filter(lambda path: not match_any(path), all_files)
filtered_files = filter(lambda path: not os.path.isdir(path), filtered_files)
filtered_files = map(lambda path: Path(path).resolve(), filtered_files)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Install dotfiles')
    parser.add_argument('--force',
        action='store_true', default=False,
        help='If target file exists it replaces it')

    options = parser.parse_args()

    for path in filtered_files:
        dst_path = os.path.expanduser('~') / path

        print(f'{dst_path} ', end='')

        if dst_path.exists():
            print(f'[Ok]')
        else:
            path.symlink_to(dst_path.resolve())
            print(f'[Done]')

