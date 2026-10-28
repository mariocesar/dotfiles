# Git worktree helpers; `wt` alone lists them. Sourced after compinit for compdef.

function wt() {
  if (( $# == 0 )) || [[ $1 == -h || $1 == --help ]]; then
    git worktree -h
    cat <<'EOF'
Shortcuts:
  wt <subcommand> [args]      git worktree, as above
  wtl [options]               git worktree list
  wta <branch>                Add a worktree for <branch> and enter it. An existing
                              worktree is only entered; a branch git knows is checked
                              out, tracking its remote; an unknown one is created
                              from HEAD.
  wtc <branch>                Enter the worktree that has <branch> checked out
  wtr [-b|--branch] [branch]  Remove a worktree, the current one by default, refusing
                              a dirty tree or the main worktree. -b also deletes its
                              branch, if merged.

Worktrees sit beside the main one as <project>-<branch>, slashes made dashes:
  ~/Projects/app + wta feature/login -> ~/Projects/app-feature-login
EOF
    return
  fi
  git worktree "$@"
}
alias wtl='git worktree list'

# The main worktree is the first --porcelain entry
function _wt_main() {
  local line
  IFS= read -r line < <(git worktree list --porcelain) || return 1
  [[ $line == 'worktree '* ]] || return 1
  print -r -- "${line#worktree }"
}

# Directory of the worktree that has <branch> checked out
function _wt_dir() {
  local line dir
  while IFS= read -r line; do
    case $line in
      'worktree '*) dir=${line#worktree } ;;
      "branch refs/heads/$1") print -r -- "$dir"; return 0 ;;
    esac
  done < <(git worktree list --porcelain 2>/dev/null)
  return 1
}

# wta feature/login -> ../<project>-feature-login, entered once it exists
function wta() {
  local branch=$1 main dir
  if (( $# != 1 )) || [[ -z $branch ]]; then
    print -u2 'Usage: wta <branch>'
    return 2
  fi
  git check-ref-format --branch "$branch" >/dev/null || return 1
  if dir=$(_wt_dir "$branch"); then
    cd -- "$dir"
    return
  fi
  main=$(_wt_main) || return 1
  dir="${main:h}/${main:t}-${branch//\//-}"
  # git tracks a known remote branch itself; checkout.defaultRemote breaks ties
  if [[ -n $(git for-each-ref "refs/heads/$branch" "refs/remotes/*/$branch") ]]; then
    git worktree add -- "$dir" "$branch" || return 1
  else
    git worktree add -b "$branch" -- "$dir" || return 1
  fi
  cd -- "$dir"
}

function wtc() {
  local dir
  if (( $# != 1 )); then
    print -u2 'Usage: wtc <branch>'
    return 2
  fi
  dir=$(_wt_dir "$1") || { print -u2 -- "No worktree for branch: $1"; return 1 }
  cd -- "$dir"
}

# Without a branch, removes the worktree you are in
function wtr() {
  local delete_branch=0 branch dir main current
  if [[ $1 == -b || $1 == --branch ]]; then
    delete_branch=1
    shift
  fi
  if (( $# > 1 )); then
    print -u2 'Usage: wtr [-b|--branch] [branch]'
    return 2
  fi
  main=$(_wt_main) || return 1
  if [[ -n $1 ]]; then
    dir=$(_wt_dir "$1") || { print -u2 -- "No worktree for branch: $1"; return 1 }
  else
    dir=$(git rev-parse --show-toplevel) || return 1
  fi
  if [[ $dir == "$main" ]]; then
    print -u2 'Refusing to remove the main worktree.'
    return 1
  fi
  branch=$(git -C "$dir" symbolic-ref --quiet --short HEAD)
  if (( delete_branch )) && [[ -z $branch ]]; then
    print -u2 'Cannot delete branch: detached HEAD.'
    return 1
  fi
  # Removed from main so a refusal (dirty tree) leaves the shell where it was
  current=$(git rev-parse --show-toplevel 2>/dev/null)
  git -C "$main" worktree remove -- "$dir" || return 1
  if [[ $current == "$dir" ]]; then
    cd -- "$main"
  fi
  if (( delete_branch )); then
    git branch -d -- "$branch"
  fi
}

# wta completes any branch, local or remote; wtc/wtr only checked-out ones
function _wt_branches() {
  local -a branches
  branches=(${(f)"$(git for-each-ref --format='%(refname:lstrip=2)' refs/heads 2>/dev/null)"})
  branches+=(${(f)"$(git for-each-ref --format='%(refname:lstrip=3)' refs/remotes 2>/dev/null)"})
  branches=(${branches:#HEAD})
  compadd -a branches
}

function _wt_worktree_branches() {
  local line
  local -a branches
  while IFS= read -r line; do
    [[ $line == 'branch refs/heads/'* ]] && branches+=("${line#branch refs/heads/}")
  done < <(git worktree list --porcelain 2>/dev/null)
  compadd -a branches
}

function _wta() { _arguments '1:branch:_wt_branches'; }
function _wtc() { _arguments '1:worktree branch:_wt_worktree_branches'; }
function _wtr() {
  _arguments '(-b --branch)'{-b,--branch}'[also delete the branch, if merged]' \
    '1:worktree branch:_wt_worktree_branches'
}

# wt is a function, so completion has to be pointed at `git worktree` by hand
function _wt() {
  words=(git worktree "${words[@][2,-1]}")
  (( CURRENT++ ))
  _normal
}
compdef _wt wt
compdef _wta wta
compdef _wtc wtc
compdef _wtr wtr
