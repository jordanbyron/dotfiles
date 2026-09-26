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
| `ssh-setup.sh` | Key generation, Keychain, `authorized_keys` from your GitHub keys, commit signing |
| `terminal/Jordan.terminal` | Terminal.app profile — SF Mono 14, option as meta, no bell |
| `link.rb` | Symlinks everything in this repo into `~` |
| `zshrc`, `zshrc.local.example` | Shell config; per-machine bits go in the untracked `~/.zshrc.local` |
| `git-worktree.zsh` | Worktree-aware `gco` / `gcm` / `gbda` / `gbds` |
| `gitconfig`, `gitignore` | Git identity, defaults and global ignores |
| `tool-versions` | Global asdf runtime versions, linked to `~/.tool-versions` |
| `nvim/` | Neovim config, linked into `~/.config/nvim` |
| `claude/` | Claude Code statusline and a sanitized `settings.json` to start from |
| `ackrc`, `gemrc`, `irbrc` | Smaller per-tool config |

### Terminal

`macos-defaults.sh` imports `terminal/Jordan.terminal` and makes it the default.
To do it by hand: quit Terminal, double-click the file, then set it as default
in Terminal → Settings → Profiles.

To re-export after changing the profile on this Mac:

```sh
python3 - <<'PY'
import os, plistlib
src = plistlib.load(open(os.path.expanduser('~/Library/Preferences/com.apple.Terminal.plist'),'rb'))
p = dict(src['Window Settings']['Jordan']); p['columnCount'] = 160; p['rowCount'] = 45
plistlib.dump(p, open('terminal/Jordan.terminal','wb'))
PY
```

### SSH

`bootstrap.sh` runs `ssh-setup.sh`, which is also fine to run on its own. It:

1. Generates `~/.ssh/id_ed25519` if the machine doesn't have one, prompting for
   a passphrase rather than silently creating an unprotected key.
2. Loads it into the agent and the login Keychain, adding a `Host *` block to
   `~/.ssh/config` so it stays loaded across reboots.
3. Fetches the keys you've published at `https://github.com/<user>.keys` and
   appends any that are missing to `~/.ssh/authorized_keys`, so you can ssh
   *into* the new Mac from your other machines.
4. Sets the key up for commit signing: adds it to `~/.ssh/allowed_signers`
   so git can verify your own signatures, and uploads it to GitHub as a
   signing key (needs `gh auth refresh -s admin:ssh_signing_key` once).
5. Offers to turn on Remote Login.

Step 3 is why nothing secret lives in this repo: public keys stay on GitHub,
and adding a key there is enough to authorize it everywhere on the next run.
The flip side is that anyone who controls that GitHub account can log into
these machines — worth a hardware 2FA key on the account.

It only ever appends to `authorized_keys`, so keys you added by hand survive.
Keys that aren't on GitHub, including older RSA ones, won't be carried over —
add them to GitHub or copy them across manually.

### Keeping the Brewfile current

```sh
brew leaves          # top-level formulae — the Brewfile should roughly match
brew list --cask
```

## Manual steps — not in this repo

These hold credentials or need a browser login, so they're deliberately not
tracked:

- **SSH** — `ssh-setup.sh` handles most of it (see below); what's left is
  adding the new Mac's public key at https://github.com/settings/keys so it
  can reach your other machines, and bringing over `~/.ssh/config` by hand if
  there are hosts worth keeping.
- **`gh` auth** — `gh auth login`, then
  `gh auth refresh -h github.com -s admin:ssh_signing_key`. The gitconfig
  credential helper depends on it, and GitHub only marks commits Verified once
  `ssh-setup.sh` has uploaded the key as a signing key. Re-run bootstrap afterwards to install `gh-signoff`, then
  `gh extension install github/gh-stack`.
- **`~/.zshrc.local`** — bootstrap copies the example; fill in this machine's
  PATH entries and credential paths.
- **`~/.netrc`, `~/.claude.json`, app keychains, 1Password, Dropbox** — sign in
  on the new Mac.
- **Claude Code** — `link.rb` links `claude/statusline.sh` to
  `~/.claude/statusline.sh`, but the statusline only shows once
  `~/.claude/settings.json` has the `statusLine` block: copy
  `claude/settings.json.example` over, or merge in the keys you want. Personal skills under `~/.claude/skills` and hooks
  under `~/.claude/hooks` are not tracked here; copy the ones you want.
- **App Store apps and non-cask apps** — Xcode, Keynote/Pages/Numbers, the
  1Password Safari extension, and anything else installed by hand.
