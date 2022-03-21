#!/usr/bin/env bash
# Copyright 2022 Alex DeLorenzo <alexdelorenzo.dev>. Licensed under the GPLv3.
export ROOT="${1:-$HOME}"
export RC="$2"
export BIN="$3"
export MAN="$4"
export SHELL="$5"

export NPM_DIR=".npm-packages"
export NPM_ROOT="$ROOT/$NPM_DIR"
export NPM_BIN="$NPM_ROOT/bin"
export NPM_MAN="$NPM_ROOT/share/man"

export BASH_RC="$HOME/.bashrc"
export ZSH_RC="$HOME/.zshrc"
export SH_RC="$HOME/.profile"

export RED='\033[0;31m'
export NC='\033[0m'

export RC_OK=0
export RC_ERR=1
export INDENT=2

set -euo pipefail
shopt -s expand_aliases extglob


alias err='>&2'
alias quiet='&>/dev/null'
alias red="printf '$RED'"
alias end="printf '$NC'"
alias indent="paste /dev/null - | expand -$INDENT"


in-red() {
  local content="${@:2}"

  red
  printf "$content"
  end
}


fail-and-exit() {
  err red
  err printf "An error prevented the script from finishing, "
  err printf "which could leave your system in an inconsistent state.\n"
  err printf "Please fix any error and run the script again.\n"
  err end

  exit $RC_ERR
}


get-shell-conf() {
  test -n "$SHELL" && local shell="$SHELL" || {
    local path="$(ps -o comm= -p "$PPID")"
    local shell="$(basename -- "$path")"
  }

  err printf "Found shell: %s\n" "$shell"

  case "$shell" in
    ?(-)bash)  printf "$BASH_RC" ;;
    ?(-)zsh)  printf "$ZSH_RC" ;;
    ?(-)sh)  printf "$SH_RC" ;;
    *)  printf "$SH_RC"

      err red
      err printf "Unrecognized shell, defaulting to %s. \n" "$SH_RC"
      err printf "Ensure your shell's variables are set manually.\n"
      err end

      return $RC_ERR
      ;;

  esac

  return $RC_OK
}


export DEFAULT_RC="$(get-shell-conf)"


expand-tilde() {
  local path="$1" 
  echo "${path/#\~/$HOME}"
}


create-paths() {
  local bin="${1:-$NPM_BIN}"
  local man="${2:-$NPM_MAN}"

  # *bsd & macos `mkdir` doesn't have long option names
  # mkdir --parents --verbose "$bin" "$man"
  mkdir -p -v "$bin" "$man"
}


set-prefix() {
  npm config set prefix "$NPM_ROOT"
}


get-vars() {
  local bin="${1:-$NPM_BIN}"
  local man="${2:-$NPM_MAN}"

  cat <<EOF
export PATH="\$PATH:$bin"
export MANPATH="\${MANPATH:-\$(manpath)}:$man"
export NPM_PACKAGES="$NPM_ROOT"
EOF
}


already-added() {
  local rc="${1:-$DEFAULT_RC}"
  local bin="${2:-$NPM_BIN}"
  local man="${2:-$NPM_MAN}"
  local vars="$(get-vars "$bin" "$man")"

  quiet grep "$vars" "$rc"
}


main() {
  local rc="$(expand-tilde "${1:-$DEFAULT_RC}")"
  local bin="$(expand-tilde "${2:-$NPM_BIN}")"
  local man="$(expand-tilde "${3:-$NPM_MAN}")"

  printf "Creating %s and %s\n" "$bin" "$man"
  create-paths "$bin" "$man" || {
    printf "Couldn't create paths: %s and %s.\n" "$bin" "$man"
    fail-and-exit
  }
  
  printf "Setting npm prefix.\n"
  set-prefix || {
    printf "Couldn't set npm prefix.\n"
    quiet type npm || \
      printf "Can't find npm in your \$PATH. Please install npm and try again.\n"

    fail-and-exit
  }

  if ! already-added "$rc" "$bin" "$man"; then
    printf "Writing shell exports to %s.\n" "$rc"
    get-vars "$bin" "$man" >> "$rc"
 
  fi || {
    printf "Unable to write to %s.\n" "$rc"
    printf "Add the following to your shell's configuration file:\n\n"
    get-vars "$bin" "$man" | indent

    fail-and-exit
  }

  printf "Done.\n\n"
  printf "To load the changes in this shell, run:\n"
  printf "\tsource %s\n" "$rc"
}


main "$RC" "$BIN" "$MAN"
