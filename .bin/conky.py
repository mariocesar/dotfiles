#!~/.pyenv/versions/global/bin/python
import sys
import argparse
import subprocess

from collections import namedtuple

ListItem = namedtuple('Item', ['name', 'to_version', 'from_version'])

def run(cmd):
    out = subprocess.run(cmd.split(), stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    return out


def do_list_upgradable():
    out = run('apt list --upgradable')
    items = [ListItem(line.split('/')[0], line.split()[1], line.split()[5]) for line in out.stdout.decode().split('\n')[1:-1]]

    for item in items:
        print(f'{item.name}\t{item.from_version} -> {item.to_version}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('function', metavar='FUNCTION_NAME', type=str, nargs=1)

    args = parser.parse_args()
    name = f'do_{args.function[0]}'

    if hasattr(sys.modules[__name__], name):
        callback = getattr(sys.modules[__name__], name)
        callback()
    else:
        print('Unknown function')
        sys.exit(1)

