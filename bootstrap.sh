#! /usr/bin/env bash
#
# Set up project
#
# Copyright (c) 2010-2017 The PyroScope Project <pyroscope.project@gmail.com>
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

test ! -x "$1" || VIRTUALENV="$1"

deactivate 2>/dev/null || true
test -z "$PYTHON" -a -x "/usr/bin/python2" && PYTHON="/usr/bin/python2"
test -z "$PYTHON" -a -x "/usr/bin/python" && PYTHON="/usr/bin/python"
test -z "$PYTHON" && PYTHON="python"

test -n "$VENV_NAME" || VENV_NAME="$(basename $(builtin cd $(dirname "$SCRIPTNAME") && pwd))"
test -x ".pyvenv/$VENV_NAME/bin/python" || ${VIRTUALENV:-/usr/bin/virtualenv} ".pyvenv/$VENV_NAME"
. ".pyvenv/$VENV_NAME/bin/activate"

backports_ssl_match_hostname="https://pypi.python.org/packages/76/21/2dc61178a2038a5cb35d14b61467c6ac632791ed05131dda72c20e7b9e23/backports.ssl_match_hostname-3.5.0.1.tar.gz#md5=c03fc5e2c7b3da46b81acf5cbacfe1e6"

for basepkg in pip setuptools wheel; do
    pip install -U $basepkg
done
python -c "import distribute" 2>/dev/null || pip uninstall -y distribute
test $(python -c "import sys; print(int(sys.version_info < (3,)))") -eq 0 \
    || pip install "$backports_ssl_match_hostname"
test $(python -c "import sys; print(int(sys.version_info < (2, 7, 9)))") -eq 0 \
    || pip install -U "requests[security]"

pip install -r docs/requirements.txt
