#!/bin/bash
#!/usr/bin/python

. $1

##Create Subinterface config
##clear
##echo -e "\n--- Building Sub-interface config" $INT_VRF $INT_IP1 $INT_IP2 $INT_IP_MASK
if [ "$INT_VRF" == "" ]; then
  echo -e "\tR1 + Sub-int" $INT_NAME "to default routing table"
  python ncc.py --host $xr_mgmt1 --port $xr_port1 -u $xr_user -p $xr_pass --do-edits dc-intfs-default-vrf --params '{"INT_NAME":"'$INT_NAME'","INT_DESC":"'$INT_DESC'","INT_IP":"'$INT_IP1'","INT_IP_MASK":"'$INT_IP_MASK'","INT_VLAN":"'$INT_VLAN'"}'
  echo -e "\tR2 + Sub-int" $INT_NAME "to default routing table"
  python ncc.py --host $xr_mgmt2 --port $xr_port2 -u $xr_user -p $xr_pass --do-edits dc-intfs-default-vrf --params '{"INT_NAME":"'$INT_NAME'","INT_DESC":"'$INT_DESC'","INT_IP":"'$INT_IP2'","INT_IP_MASK":"'$INT_IP_MASK'","INT_VLAN":"'$INT_VLAN'"}'
else
  echo -e "\tR1 + Sub-int" $INT_NAME "for VRF" $INT_VRF "with IP" $INT_IP1
  python ncc.py --host $xr_mgmt1 --port $xr_port1 -u $xr_user -p $xr_pass --do-edits dc-intfs-vrf --params '{"INT_NAME":"'$INT_NAME'","INT_DESC":"'$INT_DESC'","INT_VRF":"'$INT_VRF'","INT_IP":"'$INT_IP1'","INT_IP_MASK":"'$INT_IP_MASK'","INT_VLAN":"'$INT_VLAN'"}'
  echo -e "\tR2 + Sub-int" $INT_NAME "for VRF" $INT_VRF "with IP" $INT_IP2
  python ncc.py --host $xr_mgmt2 --port $xr_port2 -u $xr_user -p $xr_pass --do-edits dc-intfs-vrf --params '{"INT_NAME":"'$INT_NAME'","INT_DESC":"'$INT_DESC'","INT_VRF":"'$INT_VRF'","INT_IP":"'$INT_IP2'","INT_IP_MASK":"'$INT_IP_MASK'","INT_VLAN":"'$INT_VLAN'"}'
fi
##  echo -e "\n--- Sub-interface config completed! ---\n"
