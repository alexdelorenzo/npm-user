#!/usr/bin/env bash
# Copyright 2022 Alex DeLorenzo <alexdelorenzo.dev>. Licensed under the GPLv3.
export ROOT="${1:-${ROOT:-$HOME}}"
export SHELL_NAME="${2:-$SHELL_NAME}"
export SHELL_RC="${3:-$SHELL_RC}"
export BIN="${4:-$BIN}"
export MAN="${5:-$MAN}"

export NPM_DIR=".npm-packages"
export NPM_ROOT="$ROOT/$NPM_DIR"
export NPM_BIN="$NPM_ROOT/bin"
export NPM_MAN="$NPM_ROOT/share/man"

export BASH_RC="$HOME/.bashrc"
export ZSH_RC="$HOME/.zshrc"
export SH_RC="$HOME/.profile"
export DEFAULT_RC

declare -A FMT=(
  [GREEN]='\e[0;32m'
  [RED]='\e[0;31m'
  [BOLD]='\e[1m'
  [END]='\e[0m'
)

export RC_OK=0
export RC_ERR=1
export RC_QUIT=2
export INDENT=2

set -Eeuo pipefail
trap 'warn-and-exit' ERR
shopt -s expand_aliases extglob


alias err='>&2'
alias input="</dev/tty"
alias quiet='&>/dev/null'
alias quiet-err='2>/dev/null'

alias warn='err printf'
alias end-fmt='printf "${FMT[END]}"'
alias loud-warn="err fmt bold red"
alias loud-success="fmt bold green"
alias indent="paste /dev/null - | expand -$INDENT"

alias should-continue="read -ern 1 -sp $'\n[Hit enter to continue]\n' cont"
alias set-prefix='npm config set prefix "$NPM_ROOT"'
alias get-prefix="npm config get prefix"


fmt() {
  local key= color= weight=

  while true; do
    key="${1^^}"

    case "$key" in
      RED|GREEN)  color="${FMT[$key]}" ;;
      BOLD)  weight="${FMT[$key]}" ;;
      *)  break ;;

    esac

    shift
  done

  local codes="$color$weight"
  local args=("${@}")

  printf "$codes"
  printf "${args[@]}"
  end-fmt
}


warn-and-exit() {
  loud-warn "\n\nAn error prevented the script from completing, "
  loud-warn "which could leave your system in an inconsistent state.\n"
  loud-warn "Please fix any errors and run the script again.\n"

  exit $RC_ERR
}


get-shell() {
  test -n "$SHELL_NAME" && printf -- "$SHELL_NAME" || {
    local path="$(ps -o comm= -p "$PPID")"
    printf -- "$(basename -- "$path")"
  }
}


get-shell-conf() {
  local shell="$(get-shell)"
  warn -- "Shell to use rootless npm with: %s.\n" "$shell"

  case "$shell" in
    ?(-)bash)  printf "$BASH_RC" ;;
    ?(-)zsh)  printf "$ZSH_RC" ;;
    ?(-)fish)  printf "$SH_RC" ;;
    ?(-)sh)  printf "$SH_RC" ;;
    *)  printf "$SH_RC"

        loud-warn "\nUnrecognized shell, defaulting to %s.\n" "$SH_RC"
        loud-warn "Ensure your shell's variables are set manually.\n"

        return $RC_ERR
        ;;

  esac

  return $RC_OK
}


DEFAULT_RC="$(get-shell-conf)" || {
   input should-continue
   test "$cont" != "" && exit $RC_QUIT
}


expand-tilde() {
  local path="$1"
  printf "${path/#\~/$HOME}"
}


create-paths() {
  local bin="${1:-$NPM_BIN}"
  local man="${2:-$NPM_MAN}"

  # *bsd & macos `mkdir` doesn't have long option names
  # mkdir --parents --verbose "$bin" "$man"
  mkdir -p -v "$bin" "$man"
}


get-vars() {
  local bin="${1:-$NPM_BIN}"
  local man="${2:-$NPM_MAN}"
  local manpath="${MANPATH:-$(manpath)}"

  cat <<EOF
export PATH="\$PATH:$bin"
export MANPATH="$manpath:$man"
export NPM_PACKAGES="$NPM_ROOT"
EOF
} quiet-err


already-added() {
  local rc="${1:-$DEFAULT_RC}"
  local bin="${2:-$NPM_BIN}"
  local man="${3:-$NPM_MAN}"

  local vars="$(get-vars "$bin" "$man")"
  local IFS=$"\n"

  for line in "$vars"; do
    grep "$line" "$rc" || return $RC_ERR
  done
} quiet


main() {
  local rc="$(expand-tilde "${1:-$DEFAULT_RC}")"
  local bin="$(expand-tilde "${2:-$NPM_BIN}")"
  local man="$(expand-tilde "${3:-$NPM_MAN}")"

  printf "Creating %s & %s.\n" "$bin" "$man"
  create-paths "$bin" "$man" || {
    warn "Couldn't create paths: %s and %s.\n" "$bin" "$man"
    warn-and-exit
  }

  printf "Changing npm prefix from %s -> %s.\n" "$(get-prefix)" "$NPM_ROOT"
  set-prefix || {
    warn "Couldn't set npm prefix.\n"
    quiet type npm || warn \
      "Can't find npm in your \$PATH. Please install npm and try again.\n"

    warn-and-exit
  }

  printf "Updating shell configuration file: %s.\n" "$rc"
  already-added "$rc" "$bin" "$man" || {
    printf "Writing shell exports to %s.\n" "$rc"
    get-vars "$bin" "$man" >> "$rc"

  } || {
    warn "\nUnable to write to %s.\n" "$rc"
    printf "Add the following to your shell's configuration file:\n\n"
    fmt bold "$(get-vars "$bin" "$man" | indent)"

    warn-and-exit
  }

  fmt green "Completed successfully.\n\n"
  loud-success "To load the changes in this shell, run:\n"
  loud-success "\tsource %s\n\n" "$rc"
}


main "$SHELL_RC" "$BIN" "$MAN"
