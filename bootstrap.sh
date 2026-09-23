#!/usr/bin/env bash
#
# Set up a new Mac from this repo.  Safe to re-run — every step is a no-op
# when the thing is already installed.
#
#   cd ~/code/dotfiles && ./bootstrap.sh
#
# Afterwards, see README.md for the handful of things that can't be scripted
# (SSH keys, GPG keys, app logins).

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
step() { printf '\n\033[36m==> %s\033[0m\n' "$1"; }

step "Xcode command line tools"
if xcode-select -p >/dev/null 2>&1; then
  echo "already installed"
else
  xcode-select --install
  echo "Finish the installer in the GUI, then re-run this script."
  exit 1
fi

step "Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
# brew shellenv belongs in .zprofile rather than the tracked .zshrc: it runs
# once per login shell and hardcodes the Homebrew prefix.
grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null ||
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"

step "Homebrew packages (Brewfile)"
brew bundle --file="$DOTFILES/Brewfile"

step "oh-my-zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "already installed"
else
  # KEEP_ZSHRC stops the installer from replacing the .zshrc we link below.
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

step "Linking dotfiles"
ruby "$DOTFILES/link.rb"

# ~/.zshrc.local holds machine-specific config (extra PATH entries, paths to
# credentials) and is deliberately not tracked.
if [ ! -f "$HOME/.zshrc.local" ]; then
  cp "$DOTFILES/zshrc.local.example" "$HOME/.zshrc.local"
  echo "created ~/.zshrc.local from the example"
fi

step "SSH"
"$DOTFILES/ssh-setup.sh"

step "gh extensions"
# Installing an extension goes through the GitHub API, so it needs a logged-in
# gh. On a fresh Mac that's still a manual step; re-run once it's done.
if gh auth status >/dev/null 2>&1; then
  gh extension list | grep -q 'basecamp/gh-signoff' ||
    gh extension install basecamp/gh-signoff
else
  echo "gh isn't logged in — run \`gh auth login\`, then re-run this script"
fi

step "asdf plugins and runtimes"
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
for plugin in direnv golang nodejs python ruby; do
  asdf plugin list 2>/dev/null | grep -qx "$plugin" || asdf plugin add "$plugin"
done
[ -f "$HOME/.tool-versions" ] || cp "$DOTFILES/tool-versions" "$HOME/.tool-versions"
(cd "$HOME" && asdf install)

step "Neovim plugins"
PLUG="$HOME/.local/share/nvim/site/autoload/plug.vim"
[ -f "$PLUG" ] || curl -fsSLo "$PLUG" --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim --headless +PlugInstall +qa 2>/dev/null ||
  echo "run :PlugInstall inside nvim if plugins are missing"

step "fzf key bindings"
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish

step "macOS defaults"
"$DOTFILES/macos-defaults.sh"

printf '\n\033[32mDone.\033[0m Open a new terminal, then work through the manual steps in README.md.\n'
