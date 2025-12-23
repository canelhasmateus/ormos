#! /bin/bash
f="$(mktemp)"

/opt/homebrew/bin/nvim -c 'startinsert' \
  -c 'nmap ß <Esc>:wqa<CR>' -c 'imap ß <Esc>:wqa<CR>' \
  -c 'map ð <Esc>:q!<CR>' -c 'imap ð <Esc>:q!<CR>' \
  -- "$f"
written=$(cat "$f")

if [ -n "$written" ]; then

  content=$(
    cat <<-EOF
\`\`\`blurb $(date +"%Y-%m-%d %H:%M:%S %z")
   $written
\`\`\`

EOF

  )

  echo "$content" >>"${HOME}/.canelhasmateus/blurbs.md"

  true
fi
