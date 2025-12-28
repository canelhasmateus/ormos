#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = [ ]
# ///

from __future__ import annotations

import json
import re
import sqlite3
from pathlib import Path
from typing import Iterable

class Article:

    def __init__(self, date, status, resource) -> None:
        self.date = date
        self.status = status
        self.resource = resource

    def __str__(self) -> str:
        return f"""
        {{
            "date" : {self.date},
            "status" : {self.status},
            "resource": {self.resource}
        }}
        """


class ArticleHistory:
    def __init__(self, url) -> None:
        self.url = url
        self.history = []

    def add(self, article: Article) -> ArticleHistory:
        self.history.append({
            "status": article.status,
            "date": re.sub("/", "-", article.date)
        })
        return self


class CurrentState:

    def __init__(self) -> None:
        self.__state = {}

    def add(self, article: Article) -> CurrentState:
        current_state = self.__state.get(article.resource) or ArticleHistory(
            article.resource)
        current_state.add(article)
        self.__state[article.resource] = current_state

    def __iter__(self) -> Iterable[ArticleHistory]:
        return (i for i in self.__state.values())


def read_articles(path) -> Iterable[Article]:
    with open(path) as f:
        header = f.readline()
        for line in f.readlines():
            date, status, resource = line.split("\t")
            yield Article(date, status, resource)


if __name__ == "__main__":
    state = CurrentState()

    tsv = Path("~/.canelhasmateus/articles.tsv").expanduser()
    db = Path("~/.canelhasmateus/state.db").expanduser()

    for article in read_articles(tsv):
        state.add(article)

    connection = sqlite3.connect(db)
    cursor = connection.cursor()
    cursor.execute("drop table if exists bookmarks")
    cursor.execute("""
    create table bookmarks(
        url varchar(256) primary key,
        transitions blob not null  
    )
    """)

    for transition in state:
        content = json.dumps(transition.history)
        key = transition.url.strip()
        cursor.execute("""
        replace into bookmarks( url, transitions ) values ( ? , ? ) 
        """, (key, content))

    connection.commit() 