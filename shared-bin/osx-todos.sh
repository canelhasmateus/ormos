#! /bin/bash
f="${HOME}/.canelhasmateus/docs/todo.md"
p=$(dirname "$f")
p=$(realpath "$p")
/opt/homebrew/bin/nvim -c 'normal Gek' \
    -c 'nmap ß <Esc>:wqa<CR>' -c 'imap ß <Esc>:wqa<CR>' \
    -c 'map ð <Esc>:q!<CR>' -c 'imap ð <Esc>:q!<CR>' \
    -c "nnoremap nf :Telescope find_files find_command=/opt/homebrew/bin/rg,--sortr,path,--files,${p}<CR>" -- "$f"
