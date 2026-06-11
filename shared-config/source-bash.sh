# ormos bash configuration
# sourced from ~/.bashrc via ubuntu.sh

export EDITOR=nvim
export VISUAL=nvim
export GIT_EDITOR=nvim

export HISTSIZE=10000
export HISTFILESIZE=10000

# PATH additions
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.cargo/bin"

# Aliases
alias ls='eza'
alias cat='bat'
alias grep='rg'

# zoxide (smart cd) — fast Rust binary, keep eager
eval "$(zoxide init bash)"
alias cd='z'

# mise — lazy-load: stub replaces itself on first call
mise() {
	unset -f mise
	eval "$(~/.local/bin/mise activate bash)"
	mise "$@"
}

# Shared libraries
[ -f ~/.canelhasmateus/lib/source-git-magic.sh ] && source ~/.canelhasmateus/lib/source-git-magic.sh
[ -f ~/.canelhasmateus/lib/source-symlink.sh ] && source ~/.canelhasmateus/lib/source-symlink.sh
[ -f ~/.canelhasmateus/config/source-secrets-linux.sh ] && source ~/.canelhasmateus/config/source-secrets-linux.sh

# Cargo
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# fzf
if type fzf &>/dev/null; then
	# Key bindings (Ctrl+T, Alt+C, Ctrl+R)
	[ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
	# **<TAB> completions (downloaded by ubuntu.sh)
	[ -f ~/.local/share/fzf/completion.bash ] && source ~/.local/share/fzf/completion.bash
	export FZF_DEFAULT_OPTS="--no-mouse --height 50% -1 --reverse --multi --inline-info \
		--preview='(bat --style=numbers --color=always {}) | head -300' \
		--preview-window='right:hidden:wrap'"
	export FZF_DEFAULT_COMMAND="fd --type f --type l --hidden --follow --exclude .git --exclude node_modules"
	export FZF_CTRL_T_COMMAND="fd --hidden --follow --exclude .git --exclude node_modules"
fi

# bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ble.sh — syntax highlighting & line editing (bash alternative to zsh-syntax-highlighting)
[ -f ~/.local/share/blesh/ble.sh ] && source ~/.local/share/blesh/ble.sh

# Git prompt
[ -f /usr/lib/git-core/git-sh-prompt ] && source /usr/lib/git-core/git-sh-prompt
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWSTASHSTATE=1

# Colored prompt: green PWD, blue git status, default prompt
prompt_cmd() {
  local prefix='\[\e[32m\]\w\[\e[0m\]'
  local gf='\[\e[34m\] (%s)\[\e[0m\]'
  git rev-parse --git-dir &>/dev/null || gf=''
  __git_ps1 "$prefix" "\\\$ " "$gf"
}
PROMPT_COMMAND=prompt_cmd
