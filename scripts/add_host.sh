#! /usr/bin/env bash
#
# Add a hosts file and host_vars for a new Ansible target

set -e
target=${1:-my-box}

# add target to inventory
if test -f "hosts"; then
    ${EDITOR:-vi} "hosts"
else
    echo -e >hosts '# Ansible inventory\n\n[box]\n'"${target}"
fi

# add host vars folder
mkdir -p "host_vars/${target}"

# call editor for "main.yml"
if test ! -f "host_vars/${target}/main.yml"; then
    echo >>"host_vars/${target}/main.yml" "# Edit the values as they apply to *your* '$target' target host."
    echo >>"host_vars/${target}/main.yml" "# Do NOT use the provided template unchanged!"
    echo >>"host_vars/${target}/main.yml" "# You MUST at least change the 'box_ipv4' value!"
    echo >>"host_vars/${target}/main.yml" ""
    sed >>"host_vars/${target}/main.yml" <"host_vars/rpi/main.yml" \
        -e 's/ansible_ssh_/; ansible_ssh_/' \
        -e "s/; ansible_ssh_host: .*/ansible_ssh_host: $target/"
fi
${EDITOR:-vi} "host_vars/${target}/main.yml"

# add / edit the sudo password
if test -f "host_vars/${target}/secrets.yml"; then
    ${EDITOR:-vi} "host_vars/${target}/secrets.yml"
else
    echo
    echo "Now enter the password for the 'ansible_ssh_user' account you specified in 'main.yml'."
    echo
    read -sp "Enter sudo password on TARGET: " PWD \
        && echo >"host_vars/${target}/secrets.yml" "ansible_sudo_pass: $PWD"
    echo
    unset PWD
fi
