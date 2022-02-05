#!/usr/bin/env bash
# Copyright Alex DeLorenzo (alexdelorenzo.dev). Licensed under the GPLv3.
export ROOT="${1:-$HOME}"

export NPM_DIR=".npm-packages"
export NPM_ROOT="$ROOT/$NPM_DIR"
export NPM_BIN="$NPM_ROOT/bin"
export NPM_MAN="$NPM_ROOT/share/man"

export BASH_RC="$HOME/.bashrc"
export ZSH_RC="$HOME/.bashrc"
export DEFAULT_RC="$HOME/.bashrc"

export NULL="/dev/null"
test $OSTYPE == win* &&
  export NULL="NUL"


quiet() {
  "$@" &> "$NULL"
}


create-paths() {
  local bin="${1:-$NPM_BIN}"
  local man="${2:-$NPM_MAN}"

  mkdir --parents --verbose "$bin"
  mkdir --parents --verbose "$man"
}


set-prefix() {
  npm config set prefix "$NPM_ROOT"
}


already-added() {
  local rc="${1:-$DEFAULT_RC}"
  local bin="${2:-$NPM_BIN}"
  local line="export PATH=\"\$PATH:$bin\""

  quiet grep "$line" "$rc"
}


add-to-path () {
  local rc="${1:-$DEFAULT_RC}"
  local bin="${2:-$NPM_BIN}"
  local man="${3:-$NPM_MAN}"

  cat <<EOF
export PATH="\$PATH:$bin"
export MANPATH="\${MANPATH:-\$(manpath)}:$man"
EOF
}


main() {
  local rc="${1:-$DEFAULT_RC}"
  local bin="${2:-$NPM_BIN}"
  local man="${3:-$NPM_MAN}"

  printf "Creating $bin and $man\n"
  create-paths "$bin" "$man"

  printf "Setting npm prefix.\n"
  set-prefix

  if ! already-added "$rc" "$bin"; then
    printf "Writing to %s.\n" "$rc"
    add-to-path "$rc" "$bin" "$man" >> "$rc"
  fi

  printf "Done.\n\n"
  printf "To load the changes in this shell, run:\n"
  printf "\tsource $rc\n"
}


main "$2" "$3" "$4"
