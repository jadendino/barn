#!/bin/zsh

set -euo pipefail
zmodload zsh/zutil

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

error() {
  echo -e "${RED}Error:${NC} $*" >&2
  exit 1
}

warn() {
  echo -e "${YELLOW}Warning:${NC} $*" >&2
}

info() {
  echo -e "${BOLD}$*${NC}"
}

success() {
  echo -e "${GREEN}$*${NC}"
}

check_flake() {
  if [ ! -f "flake.nix" ]; then
    error "No flake.nix found. Ensure you're in the correct working directory."
  fi
}

check_nix() {
  if ! command -v nix >/dev/null 2>&1; then
    warn "Nix is not installed."
    echo "Install it using the Determinate Systems installer:"
    echo "https://github.com/DeterminateSystems/nix-installer"
    echo "After installing, restart your terminal and re-run this script."
    exit 1
  else
    success "Nix is installed"
  fi
}

check_homebrew() {
  # Ensure brew is on PATH even if zshrc was not sourced (e.g. after a failed activation)
  if ! command -v brew >/dev/null 2>&1 && [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  if ! command -v brew >/dev/null 2>&1; then
    warn "Homebrew is not installed."
    printf "Install Homebrew now? (y/n) "
    read -r REPLY
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      error "Homebrew installation aborted."
    fi
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    success "Homebrew installed"
  else
    success "Homebrew is installed"
  fi
}

rebuild_darwin() {
  local NIX_CONFIG_VALUE="experimental-features = pipe-operators  accept-flake-config = true"

  sudo NIX_CONFIG="$NIX_CONFIG_VALUE" \
    nix run nix-darwin -- switch --flake ".#$HOST" "$@"
}

rebuild_nixos() {
  sudo nixos-rebuild switch --flake ".#$HOST" "$@"
}

rebuild_remote() {
  rsync -az --delete \
    --exclude .git \
    --exclude result \
    "${0:a:h}/" "$HOST:~/barn/"

  ssh -tt "$HOST" "cd ~/barn && ./rebuild.sh $HOST $*"
}

zparseopts -D -E -remote=_remote
REMOTE=${${_remote:+true}:-false}

HOST="${1:-$(hostname)}"
shift 2>/dev/null || true
LOCAL_HOSTNAME="$(hostname)"

info "Starting rebuild for host: '$HOST'"

if [ "$REMOTE" = true ]; then
  check_flake
  rebuild_remote "$@"
else
  if [ "$HOST" != "$LOCAL_HOSTNAME" ]; then
    warn "Building configuration for hostname '$HOST' while running on '$LOCAL_HOSTNAME'."
  fi

  check_nix
  check_flake

  case "$(uname)" in
    Darwin)
      check_homebrew
      rebuild_darwin "$@"
      ;;
    Linux)
      rebuild_nixos "$@"
      ;;
    *)
      error "Unsupported platform: $(uname)"
      ;;
  esac
fi

success "Rebuild complete for host: $HOST"
