#! /bin/bash

function silently() {
	"$@" >/dev/null
}

function continuously() {
	while "$@"; do
		true
	done
}

function prompt() {
	while true; do
		echo -n "$1"
		read -r yn

		case $yn in
		[yY]) return 0 ;;
		[nN]) return 1 ;;
		*) ;;
		esac

	done
}
function atGitRoot() {
	root=$(git rev-parse --show-toplevel) &&
		silently pushd &&
		silently cd "$root" &&
		"$@" &&
		silently popd
}

function inRebase() {
	[ -d ".git/rebase-merge" ] || [ -d ".git/rebase-apply" ]
}

function pendingChanges() {
	[ -n "$(git status --porcelain=v1 2>/dev/null)" ]
}

function lastMessage() {
	git log -1 --pretty=%B
}
function currentBranch() {
	git rev-parse --abbrev-ref HEAD
}

function gitAmmend() {
	git add .
	git commit --amend --no-edit
}
function gitLease() {
	git push --force-with-lease
}

function gitPush() {
	remote="origin"
	branchName=$(currentBranch)
	git push -u ${remote} "${branchName}"
}

function gitSwap() {

	git add .
	git commit -m "tmp"
	git checkout -
}

function gitChoose() {
	git checkout $(git for-each-ref --format='%(refname:short)' refs/heads/ | fzf)
}

function gitAdvance() {
	message=$1
	function doCommit() {
		[ -z "$message" ] && {
			lastMessage=$(git log -1 --pretty=%B)

			echo -n "Build success. Commit: [${lastMessage}]: "
			read -r input

			message=${input:-$lastMessage}
		}
		git add .
		git commit -m "$message"
		return 0
	}

	git add . && ./gradlew :integrations:integration-stp-mx:test --offline && {

		pendingChanges && doCommit && inRebase &&
			prompt "Would you like to revert newly commited change to avoid conflicts in your rebase? (y/n) " &&
			git revert head --no-edit

		pendingChanges || inRebase && git rebase --continue

		return 0
	}

}

function gitStagger {
	git diff --name-only --cached | while read -r file; do
		name=$(basename "$file")
		git commit -m "$name" "$file"
	done
}

function gshove() {

	gitRepos() {
		argument="$1"
		depth="${argument:=2}"
		find . -maxdepth $depth -type d -name ".git" | xargs realpath | xargs dirname
	}

	commitMessage=$1
	depth=$2
	[[ -z $commitMessage ]] && {
		echo "Supply message"
		exit 1
	}

	gitRepos "$depth" | while read -r gitRoot; do
		git -C "$gitRoot" add . &>/dev/null
		git -C "$gitRoot" commit -m "$commitMessage" &>/dev/null
		echo -n "[$gitRoot]" && echo -ne "\t" && git -C "$gitRoot" push
	done

}

function gupdate() {
	git fetch origin master && git rebase origin/master && git push --force-with-lease
}

alias gammend="atGitRoot gitAmmend"
alias glease="gitLease"
alias gpush="gitPush"

alias gswap="atGitRoot gitSwap"
alias gstagger="atGitRoot gitStagger"

alias gadvance="atGitRoot gitAdvance"
alias gcheck="gitChoose"

