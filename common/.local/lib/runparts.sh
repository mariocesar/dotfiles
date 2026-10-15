# Sourced by the sysupgrade and pkgsync runners; helpers and context are exported to their parts,
# so a part only runs through its runner.

step() { printf '\n\033[1m⇨ %s\033[0m\n' "$*"; }
has() { command -v "$1" >/dev/null 2>&1; }
# Matches ID or ID_LIKE: CachyOS is ID=cachyos, Ubuntu and Mint list debian in ID_LIKE.
is_distro() { case " $DISTRO " in *" $1 "*) ;; *) return 1 ;; esac; }

DISTRO=
[ -f /etc/os-release ] && DISTRO=$(. /etc/os-release && echo "$ID ${ID_LIKE:-}")
export DRY DISTRO
export -f step has is_distro

# Runs each executable in ~/.local/libexec/<name>.d in name order; stops at the first failure.
run_parts() {
    local dir="$HOME/.local/libexec/$1.d" part
    [ -d "$dir" ] || { echo "$1: no $dir, run install.py" >&2; exit 1; }
    for part in "$dir"/*; do
        [ -x "$part" ] || continue
        "$part" || { echo "$1: ${part##*/} failed" >&2; exit 1; }
    done
}
