# Worktree-aware git helpers for zsh.
#
# Replaces oh-my-zsh's gco / gcm / gbda aliases with versions that understand
# git worktrees, and adds gbds for squash-merged branches. Source this from
# your zshrc:
#
#   [ -f ~/.git-worktree.zsh ] && source ~/.git-worktree.zsh
#
#   gco <branch>      checkout; if the branch lives in a worktree, cd there
#   gcm               land on the main branch in the primary worktree
#   gbda [-n] [-f]    delete branches merged into HEAD (and their worktrees)
#   gbds [-n] [-f]    delete squash-merged branches (and their worktrees)
#
# -n / --dry-run shows what would happen; -f / --force also removes dirty or
# locked worktrees.

# Fallbacks for the oh-my-zsh git plugin helpers, so this file works alone.
if ! typeset -f git_main_branch > /dev/null; then
  git_main_branch() {
    command git rev-parse --git-dir &> /dev/null || return
    local remote ref
    for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}; do
      if command git show-ref -q --verify $ref; then
        echo ${ref:t}
        return 0
      fi
    done
    for remote in origin upstream; do
      ref=$(command git rev-parse --abbrev-ref $remote/HEAD 2>/dev/null)
      if [[ $ref == $remote/* ]]; then
        echo ${ref#"$remote/"}
        return 0
      fi
    done
    echo master
    return 1
  }
fi

if ! typeset -f git_develop_branch > /dev/null; then
  git_develop_branch() {
    command git rev-parse --git-dir &> /dev/null || return
    local branch
    for branch in dev devel develop development; do
      if command git show-ref -q --verify refs/heads/$branch; then
        echo $branch
        return 0
      fi
    done
    echo develop
    return 1
  }
fi

# Shadow oh-my-zsh's aliases with the functions below.
unalias gco 2>/dev/null
unalias gcm 2>/dev/null

# gco <branch> — checkout, but if the branch already lives in a worktree, cd there.
gco() {
  local out ret
  out="$(git checkout "$@" 2>&1)"
  ret=$?

  if (( ret != 0 )) && [[ $out =~ "already used by worktree at '(.*)'" ]]; then
    local wt="$match[1]"
    if [[ -d $wt ]]; then
      cd "$wt" && print -P "%F{green}→%f worktree $wt"
      return $?
    fi
  fi

  [[ -n $out ]] && print -r -- "$out"
  return $ret
}

# gcm — always land on the main branch in the primary worktree.
gcm() {
  local main root top
  main="$(git_main_branch)" || return
  root="$(git worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p')"
  top="$(git rev-parse --show-toplevel 2>/dev/null)"

  if [[ -n $root && -d $root && $root != $top ]]; then
    cd "$root" || return
  fi

  gco "$main"
}

# Maps every branch to the worktree holding it, for _gwt_release below.
_gwt_scan() {
  typeset -gA _wt_of=() _wt_locked=()
  typeset -g _wt_primary="" _wt_here=""
  local line wt=""
  while IFS= read -r line; do
    case $line in
      worktree\ *)          wt=${line#worktree }; [[ -z $_wt_primary ]] && _wt_primary=$wt ;;
      branch\ refs/heads/*) _wt_of[${line#branch refs/heads/}]=$wt ;;
      locked*)              _wt_locked[$wt]=1 ;;
    esac
  done < <(git worktree list --porcelain) || return 1
  _wt_here="$(git rev-parse --show-toplevel 2>/dev/null)"
}

# _gwt_release <branch> <dry> <force> — free a branch from its worktree so it
# can be deleted. Returns 0 to go ahead, 1 to skip (reason printed).
_gwt_release() {
  local branch=$1 dry=$2 force=$3 wt=${_wt_of[$1]} dirty=0 why
  [[ -z $wt ]] && return 0

  if [[ $wt == $_wt_primary ]]; then
    print -P "%F{yellow}skip%f $branch — checked out in the primary worktree"
    return 1
  fi
  if [[ $wt == $_wt_here ]]; then
    print -P "%F{yellow}skip%f $branch — you are standing in its worktree ($wt)"
    return 1
  fi

  [[ -n $(git -C $wt status --porcelain 2>/dev/null) ]] && dirty=1
  if (( ! force )) && (( dirty || ${+_wt_locked[$wt]} )); then
    (( dirty )) && why="has uncommitted changes" || why="is locked"
    print -P "%F{yellow}skip%f $branch — worktree $why ($wt); use -f"
    return 1
  fi

  if (( dry )); then
    print -P "%F{cyan}would remove%f worktree $wt"
  elif (( force )); then
    git worktree remove --force --force $wt || return 1
  else
    git worktree remove $wt || return 1
  fi
}

# gbds — delete squash-merged branches, removing the worktrees that hold them.
#   -n / --dry-run   show what would be deleted
#   -f / --force     also remove dirty or locked worktrees
gbds() {
  local dry=0 force=0
  while [[ $1 == -* ]]; do
    case $1 in
      -n|--dry-run) dry=1 ;;
      -f|--force)   force=1 ;;
      *) print -u2 "gbds: unknown option $1"; return 2 ;;
    esac
    shift
  done

  local default_branch
  default_branch=$(git_main_branch) || default_branch=$(git_develop_branch) || return
  _gwt_scan || return

  local branch merge_base deleted=0 skipped=0
  while IFS= read -r branch; do
    [[ $branch == $default_branch ]] && continue

    merge_base=$(git merge-base $default_branch $branch) || continue
    [[ $(git cherry $default_branch $(git commit-tree $(git rev-parse $branch^{tree}) -p $merge_base -m _)) = -* ]] || continue

    _gwt_release $branch $dry $force || { (( skipped++ )); continue; }

    if (( dry )); then
      print -P "%F{cyan}would delete%f branch $branch"
    else
      git branch -D $branch || { (( skipped++ )); continue; }
    fi
    (( deleted++ ))
  done < <(git for-each-ref refs/heads/ --format='%(refname:short)')

  print -P "%F{green}$deleted%f squash-merged branch(es) $( (( dry )) && print -n 'would be ' )deleted, %F{yellow}$skipped%f skipped"
}

# gbda — delete branches merged into HEAD, removing the worktrees that hold them.
# Same flags as gbds. Unlike oh-my-zsh's version this reports what it skips
# instead of silently passing over worktree-held branches.
gbda() {
  local dry=0 force=0
  while [[ $1 == -* ]]; do
    case $1 in
      -n|--dry-run) dry=1 ;;
      -f|--force)   force=1 ;;
      *) print -u2 "gbda: unknown option $1"; return 2 ;;
    esac
    shift
  done

  local main_branch develop_branch
  main_branch=$(git_main_branch)
  develop_branch=$(git_develop_branch)
  _gwt_scan || return

  local branch deleted=0 skipped=0
  while IFS= read -r branch; do
    [[ $branch == $main_branch || $branch == $develop_branch ]] && continue

    _gwt_release $branch $dry $force || { (( skipped++ )); continue; }

    if (( dry )); then
      print -P "%F{cyan}would delete%f branch $branch"
    else
      git branch --delete $branch || { (( skipped++ )); continue; }
    fi
    (( deleted++ ))
  done < <(git for-each-ref refs/heads/ --format='%(refname:short)' --merged HEAD)

  print -P "%F{green}$deleted%f merged branch(es) $( (( dry )) && print -n 'would be ' )deleted, %F{yellow}$skipped%f skipped"
}
