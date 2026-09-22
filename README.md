# dotfiles

Shell, editor, git and macOS config, plus a one-shot setup script for a new Mac.

## Setting up a new Mac

```sh
git clone <this repo> ~/code/dotfiles
cd ~/code/dotfiles
./bootstrap.sh
```

`bootstrap.sh` is idempotent — re-run it any time. It installs the Xcode command
line tools, Homebrew and everything in the `Brewfile`, oh-my-zsh, the asdf
plugins and runtimes from `tool-versions`, vim-plug and the Neovim plugins, fzf
key bindings, and then applies `macos-defaults.sh`.

Open a new terminal when it finishes, then work through the manual steps below.

## What's here

| Path | What it is |
| --- | --- |
| `bootstrap.sh` | New-Mac setup, start here |
| `Brewfile` | Homebrew formulae, casks and taps (`brew bundle`) |
| `macos-defaults.sh` | System preferences: keyboard, trackpad, Finder, Dock, screenshots |
| `terminal/Basic.terminal` | Terminal.app profile — SF Mono 14, option as meta, no bell |
| `link.rb` | Symlinks everything in this repo into `~` |
| `zshrc`, `zshrc.local.example` | Shell config; per-machine bits go in the untracked `~/.zshrc.local` |
| `git-worktree.zsh` | Worktree-aware `gco` / `gcm` / `gbda` / `gbds` |
| `gitconfig`, `gitignore` | Git identity, defaults and global ignores |
| `tool-versions` | Global asdf runtime versions, linked to `~/.tool-versions` |
| `nvim/` | Neovim config, linked into `~/.config/nvim` |
| `claude/` | Claude Code statusline and a sanitized `settings.json` to start from |
| `ackrc`, `gemrc`, `irbrc` | Smaller per-tool config |

### Terminal

`macos-defaults.sh` imports `terminal/Basic.terminal` and makes it the default.
To do it by hand: quit Terminal, double-click the file, then set it as default
in Terminal → Settings → Profiles.

To re-export after changing the profile on this Mac:

```sh
python3 - <<'PY'
import plistlib
src = plistlib.load(open('/Users/$USER/Library/Preferences/com.apple.Terminal.plist','rb'))
p = dict(src['Window Settings']['Basic']); p['columnCount'] = 160; p['rowCount'] = 45
plistlib.dump(p, open('terminal/Basic.terminal','wb'))
PY
```

### Keeping the Brewfile current

```sh
brew leaves          # top-level formulae — the Brewfile should roughly match
brew list --cask
```

## Manual steps — not in this repo

These hold credentials or need a browser login, so they're deliberately not
tracked:

- **SSH keys** — generate fresh ones (`ssh-keygen -t ed25519`) and add the
  public key to GitHub rather than copying `~/.ssh` across. Bring over
  `~/.ssh/config` by hand if there are hosts worth keeping.
- **GPG keys** — export from the old Mac (`gpg --export-secret-keys --armor`)
  and import on the new one. `pinentry-mac` is in the Brewfile.
- **`gh` auth** — `gh auth login`. The gitconfig credential helper depends on
  it. Then `gh extension install basecamp/gh-signoff github/gh-stack`.
- **`~/.zshrc.local`** — bootstrap copies the example; fill in this machine's
  PATH entries and credential paths.
- **`~/.netrc`, `~/.claude.json`, app keychains, 1Password, Dropbox** — sign in
  on the new Mac.
- **Claude Code** — copy `claude/settings.json.example` to
  `~/.claude/settings.json` and `claude/statusline.sh` to
  `~/.claude/statusline.sh`. Personal skills under `~/.claude/skills` and hooks
  under `~/.claude/hooks` are not tracked here; copy the ones you want.
- **App Store apps and non-cask apps** — Xcode, Keynote/Pages/Numbers, the
  1Password Safari extension, and anything else installed by hand.
