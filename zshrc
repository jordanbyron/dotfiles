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
alias grl="grbm && gpf && gh pr edit --add-label 'ready-for-merge'"

# Worktree-aware git helpers (gco, gcm, gbda, gbds) — linked by link.rb.
[ -f ~/.git-worktree.zsh ] && source ~/.git-worktree.zsh

[ -f ~/bin/z.sh ] && source ~/bin/z.sh

if [ -f /opt/homebrew/opt/asdf/libexec/asdf.sh ]; then
  . /opt/homebrew/opt/asdf/libexec/asdf.sh

  # Hook direnv into your shell.
  eval "$(asdf exec direnv hook bash)"

  # A shortcut for asdf managed direnv.
  direnv() { asdf exec direnv "$@"; }
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

GPG_TTY=$(tty)
export GPG_TTY

export PATH="$HOME/.local/bin:$PATH"

# Machine-specific config (PATH additions, secrets paths, etc.) lives in
# ~/.zshrc.local, which is not tracked in the dotfiles repo.
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
