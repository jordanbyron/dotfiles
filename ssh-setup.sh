#!/usr/bin/env bash
#
# SSH setup for a new Mac.  Safe to re-run.
#
#   ./ssh-setup.sh
#
# Generates a key if there isn't one, loads it into the agent and Keychain,
# authorizes your published GitHub keys so you can ssh in from your other
# machines, and offers to turn on Remote Login.
#
# Authorizing GitHub's copy of your keys means whoever controls that account
# controls login to this Mac.  That's the tradeoff for not committing key
# material to a public repo, and for new keys taking effect on a re-run.

set -euo pipefail

GITHUB_USER="${GITHUB_USER:-jordanbyron}"
KEY="$HOME/.ssh/id_ed25519"
AUTHORIZED="$HOME/.ssh/authorized_keys"

step() { printf '\n\033[36m==> %s\033[0m\n' "$1"; }
confirm() { read -r -p "$1 [y/N] " reply; [[ "$reply" =~ ^[Yy]$ ]]; }

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

step "SSH key"
if [ -f "$KEY" ]; then
  echo "$KEY already exists, keeping it"
else
  # No -N: ssh-keygen prompts, so the passphrase is the user's call rather
  # than silently empty.
  ssh-keygen -t ed25519 -C "$(git config --get user.email || echo "$USER@$(hostname -s)")" -f "$KEY"
fi

step "Agent and Keychain"
grep -q "AddKeysToAgent" "$HOME/.ssh/config" 2>/dev/null || cat >> "$HOME/.ssh/config" <<'CONF'

Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
CONF
ssh-add --apple-use-keychain "$KEY" 2>/dev/null || ssh-add "$KEY"

step "Authorizing your GitHub keys for inbound ssh"
published="$(mktemp)"
trap 'rm -f "$published"' EXIT
if curl -fsS "https://github.com/${GITHUB_USER}.keys" -o "$published" && [ -s "$published" ]; then
  touch "$AUTHORIZED"
  added=0
  while read -r type material _; do
    [ -z "${material:-}" ] && continue
    if grep -qF " $material " "$AUTHORIZED" 2>/dev/null || grep -qF " $material" "$AUTHORIZED" 2>/dev/null; then
      continue
    fi
    echo "$type $material ${GITHUB_USER}@github" >> "$AUTHORIZED"
    added=$((added + 1))
  done < "$published"
  chmod 600 "$AUTHORIZED"
  echo "$(wc -l < "$published" | tr -d ' ') key(s) published by github.com/${GITHUB_USER}, $added newly authorized"
else
  echo "couldn't fetch github.com/${GITHUB_USER}.keys — add keys to $AUTHORIZED by hand"
fi

step "Remote Login"
if systemsetup -getremotelogin 2>/dev/null | grep -qi "on$"; then
  echo "already on"
elif confirm "Turn on Remote Login so you can ssh into this Mac?"; then
  sudo systemsetup -setremotelogin on ||
    echo "failed — turn it on in System Settings → General → Sharing → Remote Login"
fi

step "This machine's public key"
cat "${KEY}.pub"
echo
echo "Add it at https://github.com/settings/keys to authorize this Mac on your others."
