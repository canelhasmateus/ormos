#! python3

from __future__ import annotations
from pathlib import Path
from typing import Iterable
import re
import json


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

if __name__ == "__main__":
    import json
    import sqlite3

    state = CurrentState()
    for article in read_articles("./lists/stream/articles.tsv"):
        state.add(article)

    connection = sqlite3.connect("./lists/state/limni.db")
    cursor = connection.cursor()
    cursor.execute("drop table if exists state")
    cursor.execute("""
    create table state (
        url varchar(256) primary key,
        transitions blob not null  
    )
    """)

    for transition in state:
        content = json.dumps(transition.history)
        key = transition.url.strip()
        cursor.execute("""
        replace into state( url, transitions ) values ( ? , ? ) 
        """, (key, content))
        
    connection.commit() 