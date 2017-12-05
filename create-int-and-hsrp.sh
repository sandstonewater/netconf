#!/bin/bash
#!/usr/bin/python

. $1

##Create Subinterface config
clear
echo -e "\n--- Building HSRP config..."
##cat $1
##echo -e "\nConfiguring Routers..."

k=0
for i in ${arr_VR_INT_NET[@]}
do
  j=0
  VR_IP=`python -c 'import sys, ipaddress; net1=ipaddress.ip_network('$i'); print net1['1']'`
  INT_IP1=`python -c 'import sys, ipaddress; net1=ipaddress.ip_network('$i'); print net1['2']'`
  INT_IP2=`python -c 'import sys, ipaddress; net1=ipaddress.ip_network('$i'); print net1['3']'`
  INT_NAME=${arr_INT_NAME[$k]}
  VR_ID=${arr_INT_VLAN[$k]}
  INT_DESC=${arr_INT_DESC[$k]}
  echo -e "\nCreating HSRP for network:" $INT_DESC

  ##echo -e $VR_IP $INT_IP1 $INT_IP2
  ##echo -e $INT_IP1 $INT_IP2 $INT_NAME $VR_ID $INT_DESC '\n'

  echo -e "\tR1 HSRP VR_ID" $VR_ID "and VR_IP" $VR_IP "local interface is" $INT_NAME "with IP" $INT_IP1
  python ncc.py --host $xr_mgmt1 -u $xr_user -p $xr_pass --do-edits dc-hsrp --params '{"INT_NAME":"'$INT_NAME'","VR_ID":"'$VR_ID'","PRIO":"'$PRIO_R1'","INT_IP":"'$VR_IP'"}'
  
  echo -e "\tR2 HSRP VR_ID" $VR_ID "and VR_IP" $VR_IP "local interface is" $INT_NAME "with IP" $INT_IP2
  python ncc.py --host $xr_mgmt2 -u $xr_user -p $xr_pass --do-edits dc-hsrp --params '{"INT_NAME":"'$INT_NAME'","VR_ID":"'$VR_ID'","PRIO":"'$PRIO_R2'","INT_IP":"'$VR_IP'"}'

  k=$[k+1]
done

echo -e "\n--- HSRP config completed! ---\n"
