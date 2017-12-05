#!/bin/bash

. $1

filename_tun_pol_in_if_sum=if_summary

## Check if BGP-inbound-template files exist already, if so, delete them, to create new template.
[ -f $filename_tun_pol_in_if_sum ] && echo "deleting ... " $filename_tun_pol_in_if_sum; rm $filename_tun_pol_in_if_sum
[ -f $bgp_in_policy ] && echo "deleting ... " $bgp_in_policy; rm $bgp_in_policy

no_of_computes=${#arr_Compute_Name[@]}
j=$tun_offset
k=0
dummy_net1="u'"$dummy_net"'"

for i in ${arr_Compute_IP[@]}
do
  dummy_static_net=`python -c 'import sys, ipaddress; net1=ipaddress.ip_network('$dummy_net1'); print net1['$j+1']'`

 ##Build BGP inbound tunnel policy if statements##
  cat snippets/editconfigs/tun-policy-in-if.tmpl >> $filename_tun_pol_in_if_sum
  sed -i -e 's/{{TUN_DEST}}/'$i'/g' $filename_tun_pol_in_if_sum
  sed -i -e 's/{{DUMMY_PREFIX}}/'$dummy_static_net'/g' $filename_tun_pol_in_if_sum
  ###################################

  k=$[k+1]
  j=$[j+1]
done

python ncc.py --host $xr_mgmt --port $xr_port -u $xr_user -p $xr_pass --get-oper --named-filter route-policy --params '{"RP_NAME":"DC348_NH-WA-vPOD1"}' > $bgp_in_policy
##cat $filename_tun_pol_in_if_sum
##cat $bgp_in_policy
sed -i 's/<data xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0">/<config>/g' $bgp_in_policy
sed -i 's/<\/data>/<\/config>/g' $bgp_in_policy
sed -i '/<rpl-route-policy>route-policy '$bgp_in_policy'/r '$filename_tun_pol_in_if_sum'' $bgp_in_policy
cat $bgp_in_policy > snippets/editconfigs/$bgp_in_policy".tmpl"

python ncc.py --host $xr_mgmt -u $xr_user -p $xr_pass --do-edits $bgp_in_policy --params '{"BGP_IN_NAME":"'$bgp_in_policy'"}'
