#! /bin/bash
today=$(date +'%Y-%m-%d')
f="${HOME}/.canelhasmateus/work/${today}.md"
[[ ! -f "$f" ]] && {
    echo "$today" >"$f"
}

p=$(dirname "$f")
p=$(realpath "$p")
/opt/homebrew/bin/nvim -c 'normal Gek' \
    -c 'nmap ß <Esc>:wqa<CR>' -c 'imap ß <Esc>:wqa<CR>' \
    -c 'map ð <Esc>:cq<CR>' -c 'imap ð <Esc>:cq<CR>' \
    -c "nnoremap nf :Telescope find_files find_command=/opt/homebrew/bin/rg,--sortr,path,--files,${p}<CR>" -- "$f"

[[ $? -eq 0 ]] && {
echo "___" >>"$f"
}

