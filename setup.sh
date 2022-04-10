#!/usr/bin/env bash
set -eo pipefail

function command_exists() {
	if ! [ -x "$(command -v $1)" ]; then
		echo "Error: $1 is not installed." >&2
		exit 1
	fi
}

echo "setting up dev environment for Habits"
echo "---"
command_exists brew

# setup pre-commits
brew install go-task/tap/go-task

echo "---"
echo "finished setting up dev environment"
