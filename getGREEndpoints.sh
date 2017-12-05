#!/bin/bash
#!/usr/bin/python

export RESTORE='\033[0m'
export YELLOW='\033[00;33m'
export CYAN='\033[00;36m'

ccm_curl_path="curl -s -k -u sysadmin:sysadmin123 -X GET https://10.0.91.4"

clear
count_Compute=0
noOf_Computes=$($ccm_curl_path"/rest/v0/Systems/" | python -c 'import sys, json; print json.load(sys.stdin)["Links"]["Members@odata.count"]')
echo -e ${RESTORE} "Computes to analyse for GRE endpoints =" ${CYAN} $noOf_Computes

declare -a arr_Compute_IP
declare -a arr_Compute_Name

while [ $count_Compute -lt $noOf_Computes ]
do
  current_Compute=$($ccm_curl_path"/rest/v0/Systems" | python -c 'import sys, json; print json.load(sys.stdin)["Links"]["Members"]['$count_Compute']["@odata.id"]' | cut -d'/' -f5)
  current_Compute_Name=`$ccm_curl_path"/rest/v0/Systems/"$current_Compute | python -c 'import sys, json; print json.load(sys.stdin)["Name"]'`
  current_Compute_prefix=`echo $current_Compute_Name | cut -d'-' -f1`

  if [ "$current_Compute_prefix" == "compute" ]; then

    count_Ethernet_Ints=0
    setOf_Ethernet_Ints=$($ccm_curl_path"/rest/v0/Systems/"$current_Compute"/EthernetInterfaces" | python -c 'import sys, json; print json.load(sys.stdin)["Links"]["Members"]')
    noOf_Ethernet_Ints=$(python -c 'import sys, json; data='"$setOf_Ethernet_Ints"'; print len(data)')

    while [ $count_Ethernet_Ints -lt $noOf_Ethernet_Ints ]
    do

      current_Ethernet_Int=$($ccm_curl_path"/rest/v0/Systems/"$current_Compute"/EthernetInterfaces" | python -c 'import sys, json; print json.load(sys.stdin)["Links"]["Members"]['$count_Ethernet_Ints']["@odata.id"]')
      current_Ethernet_Desc=$($ccm_curl_path$current_Ethernet_Int | python -c 'import sys, json; print json.load(sys.stdin)["Description"]')

      if [ "$current_Ethernet_Desc" == "LAG" ]; then
        GRE_IP_endpoint=$($ccm_curl_path$current_Ethernet_Int | python -c 'import sys, json; print json.load(sys.stdin)["Oem"]["Ericsson"]["VxlanUnderlay"]["IPv4Address"]')
        echo -e ${CYAN} $current_Compute_Name ${RESTORE} "has VXLAN endpoint IP for GRE" ${CYAN} $GRE_IP_endpoint ${RESTORE}
        arr_Compute_IP[$count_Compute]="$GRE_IP_endpoint"
        arr_Compute_Name[$count_Compute]="$current_Compute_Name"
      fi

      count_Ethernet_Ints=$[count_Ethernet_Ints+1]

    done

  fi

  count_Compute=$[count_Compute+1]

done

##for i in ${arr_Compute_IP[@]}; do echo $i; done

##for j in ${arr_Compute_Name[@]}; do echo $j; done