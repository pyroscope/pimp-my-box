# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# ! FILE IS CONTROLLED BY ANSIBLE, DO NOT CHANGE, OR ELSE YOUR CHANGES WILL BE EVENTUALLY LOST !
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Common bash helper functions
#
#   source /usr/local/lib/pmb/common.sh
#

#
# Variables
#
GiB=$(( 1024 * 1024 * 1024 ))

# Make cron jobs work
grep ":$HOME/bin:" <<<":$PATH:" >/dev/null || export PATH="$HOME/bin:$PATH"


#
# Time measurement
#
now_ms() { # Milliseconds
    local nano=$(date +'%s%N')
    echo ${nano%??????}
}
now() { # Seconds with nanoseconds
    date +'%s.%N'
}
took_ms() { # "secs.mmm" from args "start [stop]"
    local start=$1
    local stop=$2
    test -n "$stop" || stop=$(now)
    printf "%.3f" $(bc <<<"$stop - $start")
}


#
# Disk management
#
bytes_free() {
    local volume="$1"
    df -PB1 "$volume" | tail -n1 | tr -s ' ' | cut -f4 -d' '
}


#
# Logging
#
fail() {
    echo >&2 "ERROR: $@"
    exit 1
}
print_gib() {
    echo -n $(bc -q <<<"scale = 3; $1 / $GiB") "GiB"
}

# EOF
