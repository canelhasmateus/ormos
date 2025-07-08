set -o emacs
# Ctrl-X edits command line

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x' edit-command-line

bindkey '^[^[[D' backward-word
bindkey '^[[1;3D' backward-word

bindkey '^[[1;3C' forward-word
bindkey '^[^[[C' forward-word

bindkey '^[[1~' beginning-of-line
bindkey '^[[1;3H' beginning-of-line
bindkey '3H' beginning-of-line

bindkey '^[[4~' end-of-line
bindkey '3F' end-of-line
bindkey '^[[1;3F' end-of-line

bindkey '^H' backward-kill-word
bindkey '^[[3~' delete-char
bindkey '^[[17~' kill-word

# Todos
#bindkey '^[^D' list-choices
#bindkey '^[^D' expand-history
#bindkey '^[^D' complete-word
#bindkey '^[^D' accept-and-menu-complete
#bindkey '^[^D' expand-or-complete-prefix
#bindkey '^[^D' expand-history
#bindkey '^[^D' expand-word
#bindkey '^[^D' menu-complete
#bindkey '^[^D' menu-expand-or-complete

# alias find='fd --type f'
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(zoxide init --cmd cd zsh)"

# fzf search
fzf=$(which fzf)
fzf=$(dirname $fzf)
fzf=$(dirname $fzf)
if [ -e "$fzf/opt/fzf/shell/completion.zsh" ]; then

	source "$fzf/opt/fzf/shell/completion.zsh"
	source "$fzf/opt/fzf/shell/key-bindings.zsh"
	FD_OPTIONS="--hidden --follow --exclude .git --exclude node_modules"
	export FZF_DEFAULT_OPTS="--no-mouse --height 50% -1 --reverse --multi --inline-info \
		--preview='(bat --style=numbers --color=always {}) | head -300' \
		--preview-window='right:hidden:wrap'\
		"
	export FZF_DEFAULT_COMMAND="fd --type f --type l $FD_OPTIONS"
	export FZF_CTRL_T_COMMAND="fd $FD_OPTIONS"

	# export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
	# --color=fg:#c0caf5,bg:#24283b,hl:#ff9e64 \
	# --color=fg+:#c0caf5,bg+:#292e42,hl+:#ff9e64 \
	# --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff \
	# --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a"

fi

function cargo_generate() {
	choices="$(cargo test -- --list --format=terse | awk {'print substr($1, 1, length($1)-1)'} | fzf | tr '\n' ' ')"
	print -z "cargo test -- $choices --exact"
}
alias ct=cargo_generate
# Todos
# brew install zsh-syntax-highlighting
# echo "source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
# source ./zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
