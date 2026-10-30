#!/bin/sh
set -eu

command -v uv >/dev/null 2>&1 || { echo "No uv, skipping"; exit 0; }

# Plugins live here, not in `llm install`, so every machine gets the same set.
uv tool install --quiet llm \
    --with llm-anthropic \
    --with llm-ollama
