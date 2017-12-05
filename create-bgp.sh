#!/bin/bash
#!/usr/bin/python

##. $file_env_ios
##. $file_env_vrfs
. $1
filename_tun_pol_in_if_sum="tun_pol_in_if_sum_"$xr_mgmt
filename_tun_pol_in_final="tun_pol_in_final_"$xr_mgmt".tmpl"

## Check if BGP-inbound-template files exist already, if so, delete them, to create new template.
[ -f snippets/editconfigs/$filename_tun_pol_in_final ] && rm snippets/editconfigs/$filename_tun_pol_in_final

##Build BGP inbound template
cat snippets/editconfigs/tun-policy-in-start.tmpl >> snippets/editconfigs/$filename_tun_pol_in_final
cat snippets/editconfigs/$filename_tun_pol_in_if_sum >> snippets/editconfigs/$filename_tun_pol_in_final
cat snippets/editconfigs/tun-policy-in-end.tmpl >> snippets/editconfigs/$filename_tun_pol_in_final

##Create BGP inbound and outbound policies
filename_tun_pol_in_final="tun_pol_in_final_"$xr_mgmt
python ncc.py --host $xr_mgmt --port $xr_port -u $xr_user -p $xr_pass --do-edits $filename_tun_pol_in_final --params '{"BGP_IN_NAME":"'$bgp_in_policy'"}'

## Create main bgp config and neighbor definitions
echo -e '\n'${CYAN}"--- Building BGP config...\n"
python ncc.py --host $xr_mgmt --port $xr_port -u $xr_user -p $xr_pass --do-edits tun-bgp --params '{"BGP_LOCAL_AS":"'$bgp_local_as'","ROUTER_ID":"'$gre_src_add'","CSC_BGP_ADD":"'$csc_bgp_add'","BGP_REMOTE_AS":"'$bgp_csc_as'","BGP_US_INT":"'$bgp_us_int'","BGP_IN_NAME":"'$bgp_in_policy'","DESCRIPTION":"BGP to CSC"}'
echo -e '\t'${YELLOW}"Creating BGP neighbor:" ${RESTORE}$csc_bgp_add ${YELLOW}"Remote AS" ${RESTORE}$bgp_csc_as ${RESTORE}

