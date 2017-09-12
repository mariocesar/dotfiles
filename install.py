import glob
import re
import os
from itertools import chain

os.chdir(os.path.dirname(os.path.abspath(__file__)))

all_files = set(chain(
    glob.glob('.*/**', recursive=True),
    glob.glob('.*', recursive=True),
    glob.glob('*', recursive=True),
))

all_files = sorted(list(all_files))

exclude_patterns = [
    re.compile('^\.git/').match,
    re.compile('^\.gitignore$').match,
    re.compile('^.*~$').match,
    re.compile('\.pyc$').match,
    re.compile('README\.md').match,
    re.compile('install\.py').match,
]

match_any = lambda path: any(map(lambda match: match(path), exclude_patterns))

filtered_files = filter(lambda path: not match_any(path), all_files)
filtered_files = filter(lambda path: not os.path.isdir(path), filtered_files)


for path in filtered_files:
    dst_path = os.path.expanduser(f'~/{path}')

    if os.path.exists(dst_path):
        print(f'{path} [Ok]')
    else:
        print(f'{path} ', end='')
        os.symlink(path, dst_path)
        print(f'[Linked]')
    
