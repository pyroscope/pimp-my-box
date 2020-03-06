#! /usr/bin/env bash
#
# Set up working environment
#
# Copyright (c) 2010-2020 The PyroScope Project <pyroscope.project@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

VENV_NAME="pimp-my-box"

SCRIPTNAME="$0"
test "$SCRIPTNAME" != "-bash" -a "$SCRIPTNAME" != "-/bin/bash" || SCRIPTNAME="${BASH_SOURCE[0]}"

test -z "$1" || { PYTHON="$1"; shift; }

deactivate 2>/dev/null || true
for _pv in 3.9 3.8 3.7 3.6 3; do
    test -z "$PYTHON" && which "python$_pv" >/dev/null 2>&1 && PYTHON="python$_pv"
done
test -z "$PYTHON" -a -x "/usr/bin/python3" && PYTHON="/usr/bin/python3"

echo "*** Creating venv for $($PYTHON -V 2>&1) ***"
echo
test -n "$VENV_NAME" || VENV_NAME="$(basename $(builtin cd $(dirname "$SCRIPTNAME") && pwd))"
test -x ".venv/bin/python" || $PYTHON -m venv --prompt "$VENV_NAME" ".venv"
. ".venv/bin/activate"

for basepkg in pip setuptools wheel; do
    python -m pip install -U $basepkg
done
python -m pip install -r docs/requirements.txt
