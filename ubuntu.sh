#! /bin/bash

set -u

function scriptDir() {
	cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd
}

function linkGroup() {
	ormosRoot=$(git -C "$(scriptDir)" rev-parse --show-toplevel)

	echo "Linking Group"
	for pair in "$@"; do

		read -r from to <<<"$pair"
		original="$ormosRoot/$from"
		symbol="$HOME/$to"

		parentDir=$(dirname "$symbol")
		mkdir -p "$parentDir"
		rm -rf "$symbol"

		ln -s "$original" "$symbol"
		echo "  $original -> $symbol"
	done
}

# ============================================================
# System packages
# ============================================================

sudo apt update
sudo apt install -y \
	curl wget git \
	build-essential pkg-config libssl-dev \
	jq ripgrep fzf eza bat btop zoxide fd-find \
	neovim tmux \
	python3 python3-pip python3-venv \
	cargo \
	unzip fontconfig xclip xsel \
	libsecret-tools flatpak

# ============================================================
# VSCode (via Microsoft apt repo)
# ============================================================

wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update
sudo apt install -y code

# ============================================================
# JetBrains Toolbox (for IntelliJ)
# ============================================================

curl -fsSL https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.4.38621.tar.gz -o /tmp/jetbrains-toolbox.tar.gz
sudo tar -xzf /tmp/jetbrains-toolbox.tar.gz -C /opt/
sudo ln -sf /opt/jetbrains-toolbox-*/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox

# ============================================================
# JetBrains Mono Nerd Font
# ============================================================

font_zip=$(mktemp)
curl -L "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip" -o "$font_zip"
mkdir -p "$HOME/.local/share/fonts"
unzip -o "$font_zip" -d "$HOME/.local/share/fonts" >/dev/null 2>&1
fc-cache -f "$HOME/.local/share/fonts"
rm -f "$font_zip"

# ============================================================
# mise (polyglot version manager: replaces sdkman, nvm, pyenv)
# ============================================================

curl https://mise.run | sh
eval "$(~/.local/bin/mise activate bash)"
mise use --global java@latest node@latest python@latest

# ============================================================
# Bash configuration
# ============================================================

bashrc="$HOME/.bashrc"
echo "" >>"$bashrc"
echo "# ormos" >>"$bashrc"
echo "source ~/.canelhasmateus/config/source-bash.sh" >>"$bashrc"

# ============================================================
# Symlinks
# ============================================================

baseGroup=(

	'../nisi/docs .canelhasmateus/docs'
	'../nisi/docs/journal-revo .canelhasmateus/work'

	'./shared-lib .canelhasmateus/lib'
	'./shared-bin .canelhasmateus/bin'
	'./shared-config .canelhasmateus/config'

	'./settings-shell .config/nvim'
	'./settings-shell/vimrc .vimrc'
	'./settings-shell/ideavimrc .ideavimrc'
	'./settings-shell/gitconfig .gitconfig'

	'./settings-vscode/settings-linux.json .config/Code/User/settings.json'
	'./settings-vscode/keybindings-linux.json .config/Code/User/keybindings.json'
)
linkGroup "${baseGroup[@]}"

# tmux
tmuxDir="$HOME/.config/tmux"
mkdir -p "$tmuxDir"
ln -sf "$(scriptDir)/settings-shell/tmux.conf" "$tmuxDir/tmux.conf"

# ============================================================
# Tmux Plugin Manager (TPM)
# ============================================================

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
	git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# ============================================================
# fzf **<TAB> completions for bash (not bundled in Ubuntu apt)
# ============================================================

mkdir -p "$HOME/.local/share/fzf"
curl -fL "https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.bash" \
	-o "$HOME/.local/share/fzf/completion.bash"

# ============================================================
# ble.sh — bash syntax highlighting (bash alternative to zsh-syntax-highlighting)
# ============================================================

if [ ! -d "$HOME/.local/share/blesh" ]; then
	git clone --depth 1 https://github.com/akinomyoga/ble.sh.git /tmp/ble.sh
	make -C /tmp/ble.sh install PREFIX="$HOME/.local/share/blesh" 2>/dev/null || {
		# fallback: copy the source directly
		mkdir -p "$HOME/.local/share/blesh"
		cp -r /tmp/ble.sh/* "$HOME/.local/share/blesh/"
	}
	rm -rf /tmp/ble.sh
fi

# ============================================================
# Ghostty — GPU-accelerated terminal
# ============================================================

flatpak install -y flathub com.mitchellh.ghostty 2>/dev/null || echo "Ghostty install skipped (flatpak may need setup)"

# ============================================================
# Vim plug (regular vim, not nvim — nvim uses lazy.nvim)
# ============================================================

curl -fL "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" \
	--create-dirs -o "$HOME/.vim/autoload/plug.vim"

# ============================================================
# VSCode extensions
# ============================================================

plugins=(
	"canelhasmateus.jewel"
	"vscodevim.vim"
	"mads-hartmann.bash-ide-vscode"
	"alefragnani.project-manager"
	"alefragnani.Bookmarks"
	"percygrunwald.vscode-intellij-recent-files"
	"usernamehw.errorlens"
	"formulahendry.code-runner"
	"ryuta46.multi-command"
	"egomobile.vscode-powertools"
)

for plugin in "${plugins[@]}"; do
	code --install-extension "$plugin" || true
done

# ============================================================
# IntelliJ configs
# ============================================================

# Discover IntelliJ config directories (from Toolbox installs)
find "$HOME/.config/JetBrains" -maxdepth 1 -name "*Idea*" -type d 2>/dev/null | while read -r configDir; do
	group=(
		"./settings-intellij/keymaps/linuxnelhas.xml ${configDir#$HOME/}/keymaps/linuxnelhas.xml"
		"./settings-intellij/templates ${configDir#$HOME/}/templates"
		"./settings-intellij/quicklists ${configDir#$HOME/}/quicklists"
		"./settings-intellij/plugins/postfix ${configDir#$HOME/}/intellij-postfix-templates_templates"
	)
	linkGroup "${group[@]}"
done

echo "Ubuntu setup finished!"
echo "1. Open IntelliJ via Toolbox and verify keymap"
echo "2. Launch nvim to auto-install plugins (lazy.nvim)"
echo "3. Run tmux and press prefix+I to install TPM plugins"
echo "4. Log out and back in for bashrc and shell changes"
echo "5. Verify mise: mise ls"
