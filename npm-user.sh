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

export GREEN='\033[0;32m'
export RED='\033[0;31m'
export NC='\033[0m'

export RC_OK=0
export RC_ERR=1
export INDENT=2

set -euo pipefail
shopt -s expand_aliases extglob


alias err='>&2'
alias quiet='&>/dev/null'

alias color-end="printf '$NC'"
alias color-red="printf '$RED'"
alias color-green="printf '$GREEN'"
alias in-red="color red"
alias in-green="color green"

alias indent="paste /dev/null - | expand -$INDENT"
alias get-prefix="npm config get prefix"


color() {
  local name="${1^^}"
  local args=("${@:2}")
  local color="${!name}"

  printf "$color"
  printf "${args[@]}"
  color-end
}


warn-and-exit() {
  err in-red "\nAn error prevented the script from completing, "
  err in-red "which could leave your system in an inconsistent state.\n"
  err in-red "Please fix any errors and run the script again.\n"

  exit $RC_ERR
}


get-shell() {
  test -n "$SHELL" && printf -- "$SHELL" || {
    local path="$(ps -o comm= -p "$PPID")"
    printf -- "$(basename -- "$path")"
  }
}


get-shell-conf() {
  local shell="$(get-shell)"
  err printf -- "Shell to use rootless npm in: %s.\n" "$shell"

  case "$shell" in
    ?(-)bash)  printf "$BASH_RC" ;;
    ?(-)zsh)  printf "$ZSH_RC" ;;
    ?(-)sh)  printf "$SH_RC" ;;
    *)  printf "$SH_RC"

      err in-red "Unrecognized shell, defaulting to %s. \n" "$SH_RC"
      err in-red "Ensure your shell's variables are set manually.\n"

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

  printf "Creating %s & %s.\n" "$bin" "$man"
  create-paths "$bin" "$man" || {
    err printf "Couldn't create paths: %s and %s.\n" "$bin" "$man"
    warn-and-exit
  }
  
  printf "Changing npm prefix from %s -> %s.\n" "$(get-prefix)" "$NPM_ROOT"
  set-prefix || {
    err printf "Couldn't set npm prefix.\n"
    quiet type npm || err printf \
      "Can't find npm in your \$PATH. Please install npm and try again.\n"

    warn-and-exit
  }

  printf "Updating shell configuration file: %s.\n" "$rc"
  already-added "$rc" "$bin" "$man" || {
    printf "Writing shell exports to %s.\n" "$rc"
    get-vars "$bin" "$man" >> "$rc"
 
  } || {
    err printf "\nUnable to write to %s.\n" "$rc"
    err printf "Add the following to your shell's configuration file:\n\n"
    get-vars "$bin" "$man" | indent

    warn-and-exit
  }

  printf "Completed successfully.\n\n"
  in-green "To load the changes in this shell, run:\n"
  in-green "\tsource %s\n\n" "$rc"
}

main "$RC" "$BIN" "$MAN"
