#! /usr/bin/env bash
#
# Install Ansible into home directory virtualenv

set -e
ansible_version="1.9.6"

# just to make sure you have the packages you need
echo "*** Checking build essentials"
test -f "/usr/share/build-essential/essential-packages-list" \
    || sudo apt-get install build-essential

echo "*** Checking virtualenv"
which virtualenv >/dev/null 2>&1 || sudo apt-get install python-virtualenv

echo "*** Checking Python development support"
test -f "/usr/bin/python-config" || sudo apt-get install python-dev

# install Ansible
base="$HOME/.local/venvs"
mkdir -p "$base"
/usr/bin/virtualenv "$base/ansible"
cd "$base/ansible"
for pypkg in pip setuptools wheel "requests[security]"; do
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
test -d "$HOME/bin" || { mkdir -p "$HOME/bin"; exec -l $SHELL; }
ln -nfs "$PWD/bin"/ansible* "$HOME/bin"

# check success
cd
echo
if ansible --version 2>&1 | grep >/dev/null "$ansible_version"; then
    echo "*** ALL OK: Ansible was installed"
else
    echo "*** ERROR: Something went wrong, calling 'ansible --version' results in:"
fi
ansible --version
which ansible
