#!/usr/bin/env python3
from __future__ import annotations

import itertools
import json
import pathlib
import sqlite3
from dataclasses import dataclass, is_dataclass, asdict
from typing import Iterable, TypeVar, List, NamedTuple

T = TypeVar("T")


def batched(rows: Iterable[T], size=100) -> List[T]:
    current = []
    for row in rows:
        current.append(row)
        if len(current) == size:
            yield current
            current = []

    if current:
        yield current


#
#

@dataclass
class Transition:
    date: str
    status: str


@dataclass
class Item:
    url: str
    transition: Transition


def contents(path: pathlib.Path) -> Iterable[Item]:
    with open(path) as f:
        f.readline()

        while True:
            line = f.readline()
            if not line:
                return
            datetime, kind, url = line.split("\t")

            yield Item(
                url.strip(),
                Transition(datetime.strip(), kind.strip())
            )


#
#

class EnhancedJSONEncoder(json.JSONEncoder):
    def default(self, o):
        if is_dataclass(o):
            return asdict(o)
        return super().default(o)


# noinspection SqlNoDataSourceInspection
class Bookmark(NamedTuple):
    id: str
    content: str


def rows(items: Iterable[Item]) -> Iterable[Bookmark]:
    for (url, items) in itertools.groupby(items, key=lambda x: x.url):
        content = json.dumps([i.transition for i in items], cls=EnhancedJSONEncoder)
        yield Bookmark(url, content)


if __name__ == '__main__':
    reads = pathlib.Path("~/.canelhasmateus/articles.tsv").expanduser()
    db = pathlib.Path("~/.canelhasmateus/state.db").expanduser()
    connection = sqlite3.connect(db)
    # noinspection SqlNoDataSourceInspection
    connection.execute("""
        create table if not exists bookmarks
        (
            url text not null unique,
            transitions text not null
        );
    """)

    for batch in batched(rows(contents(reads))):
        # noinspection SqlNoDataSourceInspection
        connection.executemany("replace into bookmarks(url, transitions) values (?,?)", batch)
    connection.commit()
