#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = [ "numpy", "pandas", "asciichartpy"]
# ///

import builtins
import re

class Redir:
    def __init__( self, callable  ):
        self.callable = callable
    
    def __getattr__(self, attr):
        return self.callable().__getattribute__( attr )

def lazymodule( name ):
    import importlib
    
    mod = None
    def callable():
        nonlocal mod
        mod = mod or importlib.import_module( name )
        return mod
    return callable

##
## 
## 
##
##

np = Redir(lazymodule("numpy"))
pd = Redir(lazymodule("pandas"))

true = True
false = False
null = None

globaloutput = []
def id():
    import uuid
    return str(uuid.uuid4())

def now():
    import datetime
    return datetime.datetime.now()

def echo( x , end = "" , **kwargs):
    x and builtins.print( x , end = end)

def print(x , **kwargs): 
    globaloutput.append( x )

def decode( x ):
    from urllib.parse import unquote
    return unquote( x )

def parts( x ):
    from urllib.parse import urlparse
    return urlparse( x )

def params( x ):
    from urllib.parse import parse_qs
    return parse_qs(x)

def tplot(x, cfg = {}):
    from asciichartpy import plot
    return plot(x , cfg)
    
if __name__ == "__main__":
    
    def readinput():
        while True:
            try:
                yield input()
            except EOFError:
                return
    
    def dedent(text):
        _whitespace_only_re = re.compile('^[ \t]+$', re.MULTILINE)
        _leading_whitespace_re = re.compile('(^[ \t]*)(?:[^ \t\n])', re.MULTILINE)

        """Remove any common leading whitespace from every line in `text`.

        This can be used to make triple-quoted strings line up with the left
        edge of the display, while still presenting them in the source code
        in indented form.

        Note that tabs and spaces are both treated as whitespace, but they
        are not equal: the lines "  hello" and "\\thello" are
        considered to have no common leading whitespace.

        Entirely blank lines are normalized to a newline character.
        """
        # Look for the longest leading string of spaces and tabs common to
        # all lines.
        text = _whitespace_only_re.sub('', text)
        indents = _leading_whitespace_re.findall(text)
        margin = indents[0] if indents else None
        for indent in indents:
            # Current line more deeply indented than previous winner:
            # no change (previous winner is still on top).
            if indent.startswith(margin):
                ...

            # Current line consistent with and no deeper than previous winner:
            # it's the new winner.
            elif margin.startswith(indent):
                margin = indent

            # Find the largest common whitespace between current line and previous
            # winner.
            else:
                for i, (x, y) in enumerate(zip(margin, indent)):
                    if x != y:
                        margin = margin[:i]
                        break

        if margin:
            text = re.sub(r'(?m)^' + margin, '', text)

        return text

    cmd = dedent("\n".join(readinput()))
    try:
        echo( eval( cmd ) )
    except Exception:
        try: 
            exec( cmd )
            match len( globaloutput ):
                case 0:
                    echo( cmd )
                case 1:
                    echo( globaloutput[ 0 ] )
                case _:
                    for out in globaloutput:
                        echo( out , end = "\n")
        except:
            echo( cmd )

