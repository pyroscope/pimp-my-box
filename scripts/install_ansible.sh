#! /usr/bin/env bash
#
# Install Ansible 2 into home directory virtualenv

set -e
ansible_version="2.9.5"
python="/usr/bin/python3"

deactivate 2>/dev/null || :

# just to make sure you have the packages you need
echo "*** Checking build essentials"
test -f "/usr/share/build-essential/essential-packages-list" \
    || sudo apt-get install build-essential

echo "*** Checking curl"
which curl >/dev/null 2>&1 || sudo apt-get install curl

echo "*** Checking venv"
$python -m venv -h >/dev/null 2>&1 || sudo apt-get install python3-venv

echo "*** Checking Python development support"
test -f "/usr/bin/python3-config" || sudo apt-get install python3-dev

echo "*** Checking ffi-dev"
test -f "/usr/share/man/man3/ffi.3.gz" || sudo apt-get install libffi-dev

echo "*** Checking openssl-dev"
test -f "/usr/include/openssl/opensslconf.h" -o -f "/usr/include/openssl/conf.h" \
    || sudo apt-get install libssl-dev


# install Ansible
base="$HOME/.local/venvs"
mkdir -p "$base"
python3 -m venv "$base/ansible2"
cd "$base/ansible2"
for pypkg in pip setuptools wheel requests; do
    bin/pip install -U "$pypkg"
done
bin/pip install "ansible==$ansible_version"

# create a configuration file
if test '!' -f ~/.ansible.cfg; then
    curl -o ~/.ansible.cfg "https://raw.githubusercontent.com/ansible/ansible/stable-1.9/examples/ansible.cfg"
    sed -i \
        -e 's~^#roles_path.*=.~roles_path = $HOME/.local/ansible/roles:~' \
        -e 's~$HOME/.ansible/tmp~$HOME/.local/ansible/tmp~' \
        ~/.ansible.cfg
fi

# make Ansible commands available by default
fix_path=''
if test ! -d "$HOME/.local/bin"; then
    mkdir -p "$HOME/.local/bin"
    PATH="$HOME/.local/bin:$PATH"
    fix_path='\n\n!!!!! IMPORTANT !!!!!'
    fix_path="$fix_path"'\nYou had no ~/.local/bin! Call this command to add it to your PATH:'
    fix_path="$fix_path"'\n\n    exec $SHELL -l\n'
    fix_path="$fix_path"'\nThis works on modern systems, otherwise you have to change ~/.bashrc or a similar config file yourself!'
fi
ln -nfs "$PWD/bin/"ansible* "$HOME/.local/bin"

# check success
cd
echo; echo
if ansible --version 2>&1 | grep >/dev/null "$ansible_version"; then
    echo "*** ALL OK: Ansible was installed"
else
    echo "*** ERROR: Something went wrong, calling 'ansible --version' results in:"
fi
ansible --version
echo -n "Ansible is found at "; which ansible | sed -re "s#$HOME/#~/#"
test -z "$fix_path" || echo -e "$fix_path"
