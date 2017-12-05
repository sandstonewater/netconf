#!/bin/bash
#!/usr/bin/python

. $1

export RESTORE='\033[0m'
export YELLOW='\033[00;33m'
export CYAN='\033[00;36m'

##Create Subinterface config
clear
echo -e "\n--- Interface config started! ---\n"
k=0
echo $NETS
while [ $k -le $NO_OF_NETS ]
do
  VR_ID=$[k+START_VRID]
  j=$[k+START_NET_OFFSET]
  CURR_NET=`python -c 'import sys, ipaddress; nets=list((ipaddress.ip_network('$START_NET').subnets(prefixlen_diff=8))); print(nets['$j'])'`
  CURR_NET="u'"$CURR_NET"'"
  export INT_IP_MASK=`python -c 'import sys, ipaddress; nets=list((ipaddress.ip_network('$START_NET').subnets(prefixlen_diff=8))); print(nets['$j'].netmask)'`
  export INT_NAME=$INT_NAME_BASE"."$[k+START_VLAN]
  export INT_VLAN=$[k+START_VLAN]
  export INT_DESC=$INT_DESC_BASE"VLAN-"$INT_VLAN
  echo $INT_NAME $INT_VLAN $INT_DESC
  if [ "$VR_ID" -eq 0 ]; then
    export INT_IP1=`python -c 'import sys, ipaddress; net1=ipaddress.ip_network('$CURR_NET'); print net1['1']'`
    export INT_IP2=`python -c 'import sys, ipaddress; net1=ipaddress.ip_network('$CURR_NET'); print net1['2']'`
    ##echo $INT_IP1 $INT_IP2 $INT_IP_MASK
    ./create-subint.sh $1
  elif [ "$VR_ID" -gt 0 ]; then 
    export INT_IP1=`python -c 'import sys, ipaddress; net1=ipaddress.ip_network('$CURR_NET'); print net1['2']'`
    export INT_IP2=`python -c 'import sys, ipaddress; net1=ipaddress.ip_network('$CURR_NET'); print net1['3']'`
    export VR_IP=`python -c 'import sys, ipaddress; net1=ipaddress.ip_network('$CURR_NET'); print net1['1']'`
    ##echo -e "\t"$VR_IP $INT_IP1 $INT_IP2 $INT_IP_MASK
    echo -e ${CYAN}"\nCreating VRRP for network:"  ${YELLOW}$INT_DESC ${RESTORE}
    ./create-subint.sh $1
    echo -e "\tR1 + VRRP VR_ID" $VR_ID "and VR_IP" $VR_IP
    python ncc.py --host $xr_mgmt1 --port $xr_port1 -u $xr_user -p $xr_pass --do-edits dc-vrrp --params '{"INT_NAME":"'$INT_NAME'","VR_ID":"'$VR_ID'","PRIO":"'$PRIO_R1'","INT_IP":"'$VR_IP'"}'

    echo -e "\tR2 + VRRP VR_ID" $VR_ID "and VR_IP" $VR_IP
    python ncc.py --host $xr_mgmt2 --port $xr_port2 -u $xr_user -p $xr_pass --do-edits dc-vrrp --params '{"INT_NAME":"'$INT_NAME'","VR_ID":"'$VR_ID'","PRIO":"'$PRIO_R2'","INT_IP":"'$VR_IP'"}'
  fi

  k=$[k+1]
done

echo -e "\n--- Interface config completed! ---\n"
