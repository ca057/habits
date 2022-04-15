#!/usr/bin/env bash
set -eo pipefail

function command_exists() {
	if ! [ -x "$(command -v $1)" ]; then
		echo "Error: $1 is not installed." >&2
		exit 1
	fi
}

function install_with_brew() {
	if ! [ -x "$(command -v $1)" ]; then
		install_from=$1
		if [ -n "$2" ]; then
			install_from=$2
		fi
		echo "$1 will be install with 'brew install $install_from'"
		brew install "$install_from"
	else
		echo "$1 already installed, skipping"
	fi
}

function install_with_gem() {
	if ! [ -x "$(command -v $1)" ]; then
		install_from=$1
		if [ -n "$2" ]; then
			install_from=$2
		fi
		echo "$1 will be installed with 'gem install $install_from'"
		gem install "$install_from"
	else
		echo "$1 already installed, skipping"
	fi
}

echo "setting up dev environment for Habits"
echo "---"
# command_exists brew
# command_exists gem

install_with_brew "pre-commit"
install_with_gem "xcpretty" 
install_with_brew "task" "go-task/tap/go-task"

pre-commit install --hook-type pre-push

echo "---"
echo "finished setting up dev environment"
