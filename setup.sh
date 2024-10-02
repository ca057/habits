#!/usr/bin/env bash
set -eo pipefail

# sudo port install libyaml
mise install -y
bundle install
pre-commit install --hook-type pre-push
