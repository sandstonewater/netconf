#!/bin/bash
#!/usr/bin/python

RESTORE='\033[0m'
YELLOW='\033[00;33m'
CYAN='\033[00;36m'

. $1

## Create static route for Spine-Leaf layer
if [ "$static_route" != "" ]; then
  IFS=", " read sr_prefix sr_nh <<< $static_route
  IFS="/" read sr_host sr_mask <<< $sr_prefix
  echo -e '\n'${CYAN}"--- Creating static route for Spine-Leaf layer...\n"
  echo -e '\t'${YELLOW}"Adding route :" ${RESTORE}$sr_host ${YELLOW} "mask" ${RESTORE}$sr_mask ${YELLOW} "next hop" ${RESTORE}$sr_nh ${RESTORE}
  python ncc.py --host $xr_mgmt --port $xr_port -u $xr_user -p $xr_pass --do-edits static-route --params '{"PREFIX_IP":"'$sr_host'","PREFIX_MASK":"'$sr_mask'","NH_IP":"'$sr_nh'"}'
fi
