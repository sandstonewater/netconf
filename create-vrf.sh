#!/bin/bash
#!/usr/bin/python

##. $file_env_ios
##. $file_env_vrfs

. $1

##Create VRF config
echo -e '\n'${CYAN}"--- Building VRF config...\n"
no_of_vrfs=${#arr_VRF_names[@]}
j=0
for z in ${arr_VRF_names[@]}
do
  current_vrf_rt=${arr_VRF_rts[$j]}
  current_vrf_rt_as=$(echo $current_vrf_rt | cut -d':' -f1)
  current_vrf_rt_index=$(echo $current_vrf_rt | cut -d':' -f2)

  current_vrf_rd=${arr_VRF_rds[$j]}
  current_vrf_rd_add=$(echo $current_vrf_rd | cut -d':' -f1)
  current_vrf_rd_index=$(echo $current_vrf_rd | cut -d':' -f2)

  ##echo $current_vrf_rt_as
  ##echo $current_vrf_rt_index
  ##echo $current_vrf_rd_add
  ##echo $current_vrf_rd_index

  echo -e ${YELLOW}"VRF:" ${RESTORE}$z ${YELLOW}'\n\t'"Route Target:"${RESTORE} $current_vrf_rt ${RESTORE} ${YELLOW}'\n\t'"Route Distinguisher:"${RESTORE} $current_vrf_rd_add":"$current_vrf_rd_index ${RESTORE}
  python ncc.py --host $xr_mgmt1 --port $xr_port1 -u $xr_user -p $xr_pass --do-edits tun-vrfs --params '{"VRF_NAME":"'$z'","RT_AS":"'$current_vrf_rt_as'","RT_INDEX":"'$current_vrf_rt_index'"}'
  python ncc.py --host $xr_mgmt2 --port $xr_port2 -u $xr_user -p $xr_pass --do-edits tun-vrfs --params '{"VRF_NAME":"'$z'","RT_AS":"'$current_vrf_rt_as'","RT_INDEX":"'$current_vrf_rt_index'"}'
  python ncc.py --host $xr_mgmt1 --port $xr_port1 -u $xr_user -p $xr_pass --do-edits tun-bgp-vrfs --params '{"BGP_AS":"'$current_vrf_rt_as'","VRF_NAME":"'$z'","RD_ADD":"'$current_vrf_rd_add'","RD_INDEX":"'$current_vrf_rd_index'"}'
  python ncc.py --host $xr_mgmt2 --port $xr_port2 -u $xr_user -p $xr_pass --do-edits tun-bgp-vrfs --params '{"BGP_AS":"'$current_vrf_rt_as'","VRF_NAME":"'$z'","RD_ADD":"'$current_vrf_rd_add'","RD_INDEX":"'$current_vrf_rd_index'"}'

  j=$[j+1]
done
