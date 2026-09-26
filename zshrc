# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH

if (( ! ${fpath[(I)/usr/local/share/zsh/site-functions]} )); then
  FPATH=/usr/local/share/zsh/site-functions:$FPATH
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export EDITOR=nvim

ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
# Add wisely, as too many plugins slow down shell startup.
plugins=(git fzf)

source $ZSH/oh-my-zsh.sh

alias gs="gsb"

# Worktree-aware git helpers (gco, gcm, gbda, gbds) — linked by link.rb.
[ -f ~/.git-worktree.zsh ] && source ~/.git-worktree.zsh

for _z in /opt/homebrew/etc/profile.d/z.sh ~/bin/z.sh; do
  [ -f "$_z" ] && source "$_z" && break
done
unset _z

if command -v asdf >/dev/null; then
  export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

  # Hook direnv into your shell.
  eval "$(asdf exec direnv hook zsh)"

  # A shortcut for asdf managed direnv.
  direnv() { asdf exec direnv "$@"; }
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="$HOME/.local/bin:$PATH"

# Machine-specific config (PATH additions, secrets paths, etc.) lives in
# ~/.zshrc.local, which is not tracked in the dotfiles repo.
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
