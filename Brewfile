# Homebrew packages for a new Mac.  Install with:  brew bundle --file=Brewfile
#
# Only top-level packages (`brew leaves`) are listed — Homebrew pulls in the
# dependencies.  Grouped by what they're for, so pruning is easy.

tap "code-yeongyu/tap"      # comment-checker, used by the Claude Code hook
tap "getsentry/tools"

# --- Shell and terminal ---------------------------------------------------
brew "coreutils"            # GNU tools (gls, gdate, ...)
brew "fzf"                  # fuzzy finder; the zsh plugin hooks it up
brew "the_silver_searcher"  # ag
brew "htop"
brew "wget"
brew "z"                    # jump to frecent directories (sourced by zshrc)

# --- Editor ---------------------------------------------------------------
brew "neovim"

# --- Version management ---------------------------------------------------
brew "asdf"                 # ruby/node/python/go/direnv — see .tool-versions

# --- Git / GitHub ---------------------------------------------------------
brew "gh"

# --- Languages and build tools --------------------------------------------
brew "cmake"
brew "protobuf"
brew "rust"
brew "scons"
brew "uv"                   # python packaging
brew "libyaml"              # required to build ruby via asdf

# --- Databases and services -----------------------------------------------
brew "postgresql@17"
brew "pgvector"
brew "libpq"
brew "redis"
brew "overmind"             # Procfile process manager

# --- Web / dev infra ------------------------------------------------------
brew "caddy"
brew "flyctl"
brew "mkcert"               # local HTTPS certs
brew "prettier"

# --- Containers -----------------------------------------------------------
brew "colima"
brew "docker"

# --- Media / imaging ------------------------------------------------------
brew "ffmpeg"
brew "exiftool"
brew "imagesnap"
brew "sox"
brew "tesseract"            # OCR
brew "vips"
brew "yt-dlp"
brew "whisper.cpp"

# --- iOS / mobile ---------------------------------------------------------
brew "xcodegen"
brew "ideviceinstaller"
brew "ipatool"
cask "android-platform-tools"

# --- Hardware / making ----------------------------------------------------
brew "arduino-cli"
brew "urh"                  # universal radio hacker

# --- Local AI -------------------------------------------------------------
brew "ollama"

# --- Claude Code helpers --------------------------------------------------
brew "code-yeongyu/tap/comment-checker", trusted: true
brew "getsentry/tools/sentry-wizard", trusted: true

# --- Misc -----------------------------------------------------------------
brew "cliclick"             # scripted mouse/keyboard clicks
brew "testdisk"

# --- Casks ----------------------------------------------------------------
cask "blackhole-2ch"        # virtual audio device
cask "db-browser-for-sqlite"
cask "firefox"
cask "flycut"               # clipboard history
cask "google-chrome"
cask "keepingyouawake"
cask "mitmproxy"
cask "ngrok"

# --- Optional: apps installed by hand on the old Mac ----------------------
# Uncomment the ones worth carrying over.
# cask "1password"
# cask "docker-desktop"
# cask "zoom"
# cask "claude"
