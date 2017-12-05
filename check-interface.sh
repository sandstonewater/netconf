#!/bin/bash
#!/usr/bin/python

export RESTORE='\033[0m'
export YELLOW='\033[00;33m'
export CYAN='\033[00;36m'
export RED=$(tput setaf 1)
export WHITE=$(tput setaf 7)
export GREEN=$(tput setaf 2)

  ##Check operational status of interface##
  python ncc.py --host $1 --port $5 -u $2 -p $3 --get-oper --named-filter intf-brief --params '{"INTF_NAME":"'$4'"}' > line-state
  line_state=$(grep -oPm1 "(?<=<line-state>)[^<]+" line-state)
  if [ "$line_state" == "im-state-down" ]; then
    echo "${WHITE}$4 is ${RED}$line_state ${WHITE}"
  elif [ "$line_state" == "im-state-admin-down" ]; then
    echo "${WHITE}$4 is ${RED}$line_state ${WHITE}"
  else
    echo "${WHITE}$4 is ${GREEN}$line_state ${WHITE}"
  fi
  ##########################################
