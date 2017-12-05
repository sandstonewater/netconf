#!/bin/bash
#!/usr/bin/python

export RESTORE='\033[0m'
export YELLOW='\033[00;33m'
export CYAN='\033[00;36m'
export RED=$(tput setaf 1)
export WHITE=$(tput setaf 7)
export GREEN=$(tput setaf 2)

  ##Check operational status of interface##
  python ncc.py --host $1 -u $2 -p $3 --get-oper --named-filter intf-get --params '{"INT_NAME":"'$4'"}' > tun-state
  ##python ncc.py --host $1 -u $2 -p $3 -g > tun-state
  tun_state=$(cat tun-state | grep shut)
  echo $tun_state
  if [ "$tun_state" == "<shutdown/>" ]; then
    echo "${WHITE}$4 is ${RED}$tun_state ${WHITE}"
  else
    echo "${WHITE}$4 is ${GREEN}$tun_state ${WHITE}"
  fi
  ##echo -e ${WHITE}$4 ${RESTORE}"is" $tun_color
  ##########################################
