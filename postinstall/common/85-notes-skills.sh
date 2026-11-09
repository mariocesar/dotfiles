#!/bin/sh
set -eu

# Notebooks are private and synced outside git, so their skills are linked per machine.
skills=~/.claude/skills
conflicts=0

mkdir -p "$skills"
for src in ~/.notes/named/*/skills/*/; do
    src=${src%/}
    [ -f "$src/SKILL.md" ] || continue
    name=${src##*/}
    dest=$skills/$name
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo "Skill $name already linked to $src"
    elif [ -e "$dest" ] || [ -L "$dest" ]; then
        target=$(readlink "$dest" || echo "a real directory")
        echo "Skill name conflict: $dest is $target, not linking $src" >&2
        conflicts=$((conflicts + 1))
    else
        ln -s "$src" "$dest"
        echo "Linked skill $name to $src"
    fi
done

[ "$conflicts" -eq 0 ]
