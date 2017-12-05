#!/bin/bash
#!/usr/bin/python

##. $file_env_ios
##. $file_env_vrfs
. $1

filename_tun_pol_in_if_sum="tun_pol_in_if_sum_"$xr_mgmt

## Check if BGP-inbound-template files exist already, if so, delete them, to create new template.
[ -f snippets/editconfigs/$filename_tun_pol_in_if_sum ] && rm snippets/editconfigs/$filename_tun_pol_in_if_sum

## Create static route for Spine-Leaf layer
./create-static.sh $1

## Print table headers for tunnel details
echo -e '\n'${CYAN}"--- Building GRE/MPLS config...\n" ${YELLOW}
printf "%-15s | %-20s | %-30s | %-15s | %-15s | %-15s" "Tunnel Name" "Tunnel Status" "Dest Compute Name" "Dest Compute IP" "Dummy Route" "MPLS Label"
echo -e ${RESTORE}


## Use for loop to apply config for Tunnels, dummy static routes and static mpls paths
no_of_computes=${#arr_Compute_Name[@]}
j=$tun_offset
k=0
for i in ${arr_Compute_IP[@]}
do
  tunnel_number=$[$tunnel_base+$j]
  tunnel_name="tunnel-ip$tunnel_number"
  mpls_label=$[$mpls_label_base+$j]
  dummy_net1="u'"$dummy_net"'"
  dummy_static_net=`python -c 'import sys, ipaddress; net1=ipaddress.ip_network('$dummy_net1'); print net1['$j+1']'`
  current_compute=${arr_Compute_Name[$k]}
  TUNNEL_DESC=$dc_vpod_name$current_compute

  ##echo -e ${CYAN} $tunnel_name $bgp_us_int $gre_src_add ${RESTORE}
  python ncc.py --host $xr_mgmt --port $xr_port -u $xr_user -p $xr_pass --do-edits tun-gre --params '{"TUN_NAME":"'$tunnel_name'","TUN_DESC":"'$TUNNEL_DESC'","TUN_SRC_IP":"'$gre_src_add'","TUN_SRC_INT":"'$bgp_us_int'","TUN_DEST":"'$i'"}'
  python ncc.py --host $xr_mgmt --port $xr_port -u $xr_user -p $xr_pass --do-edits tun-static --params '{"DUMMY_PREFIX":"'$dummy_static_net'","TUN_NAME":"'$tunnel_name'"}'
  
  ##echo -e ${CYAN} $tunnel_name $mpls_label $dummy_static_net ${RESTORE}
  python ncc.py --host $xr_mgmt --port $xr_port -u $xr_user -p $xr_pass --do-edits tun-mpls --params '{"TUN_NAME":"'$tunnel_name'","MPLS_LABEL":"'$mpls_label'", "DUMMY_PREFIX":"'$dummy_static_net'"}'

  ##Check operational status of GRE tunnel##
  python ncc.py --host $xr_mgmt --port $xr_port -u $xr_user -p $xr_pass --get-oper --named-filter intf-brief --params '{"INTF_NAME":"'$tunnel_name'"}' > tun-state
  tun_state=$(grep -oPm1 "(?<=<line-state>)[^<]+" tun-state)
  if [ "$tun_state" == "im-state-down" ]; then
    tun_color="${RED}$tun_state ${WHITE}"
  else
    tun_color="${GREEN}$tun_state ${WHITE}"
  fi
  printf "%-15s | %-30s | %-30s | %-15s | %-15s | %-15s\n" "$tunnel_name" "$tun_color" "$current_compute" "$i" "$dummy_static_net" "$mpls_label"
  ##########################################

  ##Build BGP inbound tunnel policy if statements##
  cat snippets/editconfigs/tun-policy-in-if.tmpl >> snippets/editconfigs/$filename_tun_pol_in_if_sum
  sed -i -e 's/{{TUN_DEST}}/'$i'/g' snippets/editconfigs/$filename_tun_pol_in_if_sum
  sed -i -e 's/{{DUMMY_PREFIX}}/'$dummy_static_net'/g' snippets/editconfigs/$filename_tun_pol_in_if_sum
  ###################################

  k=$[k+1]
  j=$[j+1]
done


