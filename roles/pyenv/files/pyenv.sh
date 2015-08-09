# pyenv activation
#
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# ! FILE IS CONTROLLED BY ANSIBLE, DO NOT CHANGE, OR ELSE YOUR CHANGES WILL BE EVENTUALLY LOST !
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

export PYENV_ROOT="$HOME/.local/pyenv"
grep ":$PYENV_ROOT/bin:" <<<":$PATH:" >/dev/null \
    || export PATH="$PYENV_ROOT/bin:$PATH"

# eval "$(pyenv init -)"
grep ":$PYENV_ROOT/shims:" <<<":$PATH:" >/dev/null \
    || export PATH="$PYENV_ROOT/shims:$PATH"
export PYENV_SHELL=bash
source "$PYENV_ROOT/completions/pyenv.bash"
pyenv rehash 2>/dev/null

pyenv() {
  local command
  command="$1"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
  activate|deactivate|rehash|shell)
    eval "`pyenv "sh-$command" "$@"`";;
  *)
    command pyenv "$command" "$@";;
  esac
}

# eval "$(pyenv virtualenv-init -)"
export PYENV_VIRTUALENV_INIT=1

_pyenv_virtualenv_hook() {
  if [ -n "$PYENV_ACTIVATE" ]; then
    if [ "$(pyenv version-name 2>/dev/null || true)" = "system" ]; then
      eval "$(pyenv sh-deactivate --no-error --verbose)"
      unset PYENV_DEACTIVATE
      return 0
    fi
    if [ "$PYENV_ACTIVATE" != "$(pyenv prefix 2>/dev/null || true)" ]; then
      if eval "$(pyenv sh-deactivate --no-error --verbose)"; then
        unset PYENV_DEACTIVATE
        eval "$(pyenv sh-activate --no-error --verbose)" || unset PYENV_DEACTIVATE
      else
        eval "$(pyenv sh-activate --no-error --verbose)"
      fi
    fi
  else
    if [ -z "$VIRTUAL_ENV" ] && [ "$PYENV_DEACTIVATE" != "$(pyenv prefix 2>/dev/null || true)" ]; then
      eval "$(pyenv sh-activate --no-error --verbose)" || true
    fi
  fi
}

if ! [[ "$PROMPT_COMMAND" =~ _pyenv_virtualenv_hook ]]; then
  PROMPT_COMMAND="_pyenv_virtualenv_hook;$PROMPT_COMMAND";
fi
