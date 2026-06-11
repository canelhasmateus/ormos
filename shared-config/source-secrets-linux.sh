# Linux secrets helper
# Uses secret-tool (libsecret) — apt install libsecret-tools
# Drop-in replacement for macOS source-secrets.sh (security command)

function addkey() {
	key="$1"
	if type secret-tool &>/dev/null; then
		echo -n | secret-tool store --label="$key" user "$LOGNAME" service "$key"
	else
		echo "addkey: secret-tool not available. Install libsecret-tools."
		return 1
	fi
}

function getkey() {
	key="$1"
	if type secret-tool &>/dev/null; then
		secret-tool lookup user "$LOGNAME" service "$key"
	else
		echo "getkey: secret-tool not available. Install libsecret-tools."
		return 1
	fi
}

function delkey() {
	key="$1"
	if type secret-tool &>/dev/null; then
		secret-tool clear user "$LOGNAME" service "$key"
	else
		echo "delkey: secret-tool not available. Install libsecret-tools."
		return 1
	fi
}
