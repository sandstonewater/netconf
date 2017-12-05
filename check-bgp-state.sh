#!/bin/bash
#!/usr/bin/python

## Source all necessary user-input variables from this environment file
. $file_env_ios
##. $file_env_vrfs


## Check BGP neighbor state
##clear
echo -e '\n'${CYAN}"--- Confirming BGP Neighbor session status...\n"
##w=0
##for w in ${arr_Compute_IP[@]}
##do
  ##Check BGP neighbor state
  python ncc.py --host $xr_mgmt -u $xr_user -p $xr_pass --get-oper --named-filter oc-bgp --params '{"NBR_IP":"'$csc_bgp_add'"}' > bgp-state
  bgp_state=$(grep -oPm1 "(?<=<session-state>)[^<]+" bgp-state)
  if [ "$bgp_state" == "ESTABLISHED" ]; then
    bgp_color="${GREEN}$bgp_state ${WHITE}"
  else
    bgp_color="${RED}$bgp_state ${WHITE}"
  fi
  echo -e '\t'${YELLOW}"BGP neighbor:" ${RESTORE}$w ${YELLOW}"Session State" $bgp_color ${RESTORE}

##done
echo -e '\n'${CYAN}"--- BGP session state check completed ---\n"${RESTORE}
