#!/bin/bash
#!/usr/bin/python

. $1

export RESTORE='\033[0m'
export YELLOW='\033[00;33m'
export CYAN='\033[00;36m'

##Create Subinterface config
clear
echo -e "\n--- Interface deletion started! ---\n"
k=0
echo $NETS
while [ $k -le $NO_OF_NETS ]
do
  j=$[k+START_NET_OFFSET]
  export INT_NAME=$INT_NAME_BASE"."$[k+START_VLAN]
  ##echo $INT_NAME 
  ./delete-subint.sh $1
  ./delete-vrrp.sh $1
  k=$[k+1]
done

echo -e "\n--- Interface deletion completed! ---\n"
