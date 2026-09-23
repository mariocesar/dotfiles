#!/bin/sh
set -eu

command -v uv >/dev/null 2>&1 || { echo "No uv, skipping"; exit 0; }

# uv tool venvs have no pip, so `llm install` fails; plugins are declared here instead.
uv tool install --quiet llm \
    --with llm-anthropic \
    --with llm-ollama
