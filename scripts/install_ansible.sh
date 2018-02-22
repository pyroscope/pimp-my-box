#! /usr/bin/env bash
#
# Install Ansible into home directory virtualenv

set -e
ansible_version="1.9.6"
python="/usr/bin/python2"

# just to make sure you have the packages you need
echo "*** Checking build essentials"
test -f "/usr/share/build-essential/essential-packages-list" \
    || sudo apt-get install build-essential

echo "*** Checking curl"
which curl >/dev/null 2>&1 || sudo apt-get install curl

echo "*** Checking virtualenv"
which virtualenv >/dev/null 2>&1 || sudo apt-get install python-virtualenv

echo "*** Checking Python development support"
test -f "/usr/bin/python-config" || sudo apt-get install python-dev

echo "*** Checking ffi-dev"
test -f "/usr/share/man/man3/ffi.3.gz" || sudo apt-get install libffi-dev

echo "*** Checking openssl-dev"
test -f "/usr/include/openssl/opensslconf.h" || sudo apt-get install libssl-dev


# install Ansible
base="$HOME/.local/venvs"
mkdir -p "$base"
/usr/bin/virtualenv -p $python "$base/ansible"
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
fix_path=''
if test ! -d "$HOME/bin"; then
    mkdir -p "$HOME/bin"
    PATH="$HOME/bin:$PATH"
    fix_path='\n\n!!!!! IMPORTANT !!!!!'
    fix_path="$fix_path"'\nYou had no ~/bin! Call this command to add it to your PATH:'
    fix_path="$fix_path"'\n\n    exec $SHELL -l\n'
fi
ln -nfs "$PWD/bin"/ansible* "$HOME/bin"

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
