"""Tacker tool."""

import os
import json
import click
import datetime

BASE_DIR = os.path.dirname(os.path.abspath(__file__))


class JSONEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, datetime.datetime):
            return o.isoformat()

        return json.JSONEncoder.default(self, o)


class JSONDecoder(json.JSONDecoder):
    pass


class Store:
    _records = []
    store_path = os.path.join(BASE_DIR, 'records.json')

    def __init__(self):
        if not os.path.exists(self.store_path):
            f = open(self.store_path, 'w')
            f.write('[]')
            f.close()

    @property
    def records(self):
        if not self._records:
            self.load()
        return self._records

    def load(self):
        self._records = json.load(open(self.store_path, 'r'), cls=JSONDecoder)

    def commit(self):
        json.dump(self.records, open(self.store_path, 'w'), cls=JSONEncoder)

    def append(self, description, commit=True):
        self._records.append({
            'description': description,
            'timestamp': datetime.datetime.now()})

        if commit:
            self.commit()

store = Store()


@click.group()
def track():
    pass


@track.command()
@click.option('-m', '--message', prompt=True)
def start(message):
    """Start tracking activity."""
    store.append(message)


@track.command()
def stop():
    """Stop tracking current activity."""
    click.echo('Start tracking')


@track.command(name='list')
def list_activities():
    """Stop tracking current activity."""
    for activity in store.records:
        click.echo('{timestamp} - {description}'.format(**activity))

if __name__ == "__main__":
    track()
