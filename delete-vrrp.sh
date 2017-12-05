#!/bin/bash
#!/usr/bin/python

. $1

##Create Subinterface config
##clear
##echo -e "\n--- Deleting vrrp config" $INT_VRF $INT_IP1 $INT_IP2 $INT_IP_MASK
  echo -e "\tR1 - VRRP" $INT_NAME "deleted"
  python ncc.py --host $xr_mgmt1 --port $xr_port1 -u $xr_user -p $xr_pass --do-edits dc-del-vrrp --params '{"INT_NAME":"'$INT_NAME'"}'
  echo -e "\tR2 - VRRP" $INT_NAME "deleted\n"
  python ncc.py --host $xr_mgmt2 --port $xr_port2 -u $xr_user -p $xr_pass --do-edits dc-del-vrrp --params '{"INT_NAME":"'$INT_NAME'"}'
##  echo -e "\n--- Deleting vrrp config completed! ---\n"
