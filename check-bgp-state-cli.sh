#!/bin/bash
#!/usr/bin/python

. colors
## Check BGP neighbor state
##clear
echo -e '\n'${CYAN}"--- Confirming BGP Neighbor session status...\n"
##w=0
##for w in ${arr_Compute_IP[@]}
##do
  ##Check BGP neighbor state
  python ncc.py --host $1 --port $2 -u $3 -p $4 --get-oper --named-filter oc-bgp --params '{"NBR_IP":"'$5'"}' > bgp-state
  bgp_state=$(grep -oPm1 "(?<=<session-state>)[^<]+" bgp-state)
  if [ "$bgp_state" == "ESTABLISHED" ]; then
    bgp_color="${GREEN}$bgp_state ${WHITE}"
  else
    bgp_color="${RED}$bgp_state ${WHITE}"
  fi
  echo -e '\t'${YELLOW}"BGP neighbor:" ${RESTORE}$5 ${YELLOW}"Session State" $bgp_color ${RESTORE}

##done
echo -e '\n'${CYAN}"--- BGP session state check completed ---\n"${RESTORE}
