#!/usr/bin/env bash
# Copyright 2022 Alex DeLorenzo <alexdelorenzo.dev>. Licensed under the GPLv3.
export ROOT="${1:-$HOME}"

export NPM_DIR=".npm-packages"
export NPM_ROOT="$ROOT/$NPM_DIR"
export NPM_BIN="$NPM_ROOT/bin"
export NPM_MAN="$NPM_ROOT/share/man"

export BASH_RC="$HOME/.bashrc"
export ZSH_RC="$HOME/.zshrc"
export DEFAULT_RC="$BASH_RC"

export RC_ERR=1
export INDENT=4

alias indent="paste /dev/null - | expand -$INDENT"


quiet() {
  "$@" &> /dev/null
}


expand-tilde() {
  local path="$1"
 
  echo "${path/#\~/$HOME}"
}
export -f expand-tilde


create-paths() {
  local bin="${1:-$NPM_BIN}"
  local man="${2:-$NPM_MAN}"

  mkdir --parents --verbose "$bin"
  mkdir --parents --verbose "$man"
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

  printf "Creating $bin and $man\n"
  create-paths "$bin" "$man" || {
    printf "Couldn't create paths.\n"  
    return $RC_ERR
  }
  
  printf "Setting npm prefix.\n"
  set-prefix || {
    printf "Couldn't set prefix.\n"  
    return $RC_ERR
  }

  if ! already-added "$rc" "$bin" "$man"; then
    printf "Writing to %s.\n" "$rc"
    get-vars "$bin" "$man" >> "$rc"
 
  fi || {
    printf "Unable to write to $rc.\n"
    printf "Add the following to your shell's configuration file:\n\n"

    get-vars "$bin" "$man" | indent
    return $RC_ERR
  }

  printf "Done.\n\n"
  printf "To load the changes in this shell, run:\n"
  printf "\tsource $rc\n"
}


main "$2" "$3" "$4"
