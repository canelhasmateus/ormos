#! /bin/zsh
eval "$(/opt/homebrew/bin/brew shellenv)"
source ~/.canelhasmateus/lib/source-zsh.sh

choice=$(fzf << EOF
docs
configs
thorsten
EOF
)


if [[ "$choice" == "docs" ]] ; then
  cd nisi
  filename="$(date +"%Y-%m-%d").md"
  [[ -e "$filename" ]] || touch filename
  tmux new-session -A -s docs "nvim -O $filename ./docs/todo.md"
fi

if [[ "$choice" == "configs" ]] ; then
  cd ormos
  tmux new-session -A -s configs "nvim"
fi

if [[ "$choice" == "thorsten" ]] ; then
  cd thorsten
  tmux new-session -A -s thorsten "nvim"
fi
