#!/bin/bash
#!/usr/bin/python

. $1

##Create Subinterface config
  clear
  echo -e "\n--- Building VRRP config...\n"
  cat $1
  echo -e "\nConfiguring Routers..."
  python ~/ncc.py --host $xr_mgmt1 -u $xr_user -p $xr_pass --do-edits dc-vrrp --params '{"INT_NAME":"'$INT_NAME'","VR_ID":"'$VR_ID'","PRIO":"'$PRIO_R1'","INT_IP":"'$INT_IP'"}'
  echo -e "Router 1 configured with VRRP interface" $INT_NAME "VR_ID" $VR_ID "with IP" $INT_IP  
  python ~/ncc.py --host $xr_mgmt2 -u $xr_user -p $xr_pass --do-edits dc-vrrp --params '{"INT_NAME":"'$INT_NAME'","VR_ID":"'$VR_ID'","PRIO":"'$PRIO_R2'","INT_IP":"'$INT_IP'"}'
  echo -e "Router 2 configured with VRRP interface" $INT_NAME "VR_ID" $VR_ID "with IP" $INT_IP  
  echo -e "\n--- VRRP config completed! ---\n"
