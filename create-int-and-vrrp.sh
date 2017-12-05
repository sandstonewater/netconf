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
for i in ${arr_VR_INT_NET[@]}
do
  j=0
  VR_ID=${arr_INT_VRID[$k]}
  export INT_IP_MASK=`python -c 'import sys, ipaddress; net1=ipaddress.ip_network('$i'); print net1.netmask'`
  export INT_NAME=${arr_INT_NAME[$k]}"."${arr_INT_VLAN[$k]}
  export INT_VLAN=${arr_INT_VLAN[$k]}
  export INT_DESC=${arr_INT_DESC[$k]}
  if [ "$VR_ID" -eq 0 ]; then
    echo -e ${CYAN}"\nCreating sub-interface network:" ${YELLOW}$INT_DESC ${RESTORE}
    export INT_IP1=`python -c 'import sys, ipaddress; net1=ipaddress.ip_network('$i'); print net1['1']'`
    export INT_IP2=`python -c 'import sys, ipaddress; net1=ipaddress.ip_network('$i'); print net1['2']'`
    ./create-subint.sh $1
  elif [ "$VR_ID" -gt 0 ]; then 
    VR_IP=`python -c 'import sys, ipaddress; net1=ipaddress.ip_network('$i'); print net1['1']'`
    export INT_IP1=`python -c 'import sys, ipaddress; net1=ipaddress.ip_network('$i'); print net1['2']'`
    export INT_IP2=`python -c 'import sys, ipaddress; net1=ipaddress.ip_network('$i'); print net1['3']'`
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
