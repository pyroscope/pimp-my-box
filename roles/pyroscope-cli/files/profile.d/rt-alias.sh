# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# ! FILE IS CONTROLLED BY ANSIBLE, DO NOT CHANGE, OR ELSE YOUR CHANGES WILL BE EVENTUALLY LOST !
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# "pimp-my-box" default shell aliases

# activate 'pyrocore' virtualenv
test ! -f ~/lib/pyroscope/bin/activate || . ~/lib/pyroscope/bin/activate

# rtorrent aliases
alias rtlistmethods='rtxmlrpc system.listMethods | egrep'
alias rtjustnow="rtcontrol loaded=-5i -qofiles"
alias rt2days="rt-completion completed=-2d"
alias rt7days="rt-completion completed=-7d"
alias rt-completion="rtcontrol --column-headers -scompleted -ocompletion"
alias rt-stats-msg="rtcontrol -q -s alias,is_open,message -o alias,is_open,message 'message=?*' message=\!*Tried?all?trackers* | uniq -c"
alias rt-stats-seeding='rtcontrol --summary -qco leechtime,seedtime,size.sz,uploaded.sz,ratio.pc'
alias rt-stats-trackers='rtcontrol -s alias -qo alias '\''*'\'' | uniq -c | sort -n'

# END rt-alias.sh
