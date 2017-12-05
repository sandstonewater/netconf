#!/bin/bash
#!/usr/bin/python

export RESTORE='\033[0m'
export YELLOW='\033[00;33m'
export CYAN='\033[00;36m'
export RED=$(tput setaf 1)
export WHITE=$(tput setaf 7)
export GREEN=$(tput setaf 2)

## Source all necessary user-input variables from this environment file
export file_env_ios=$1
##export file_env_vrfs=$2

. $file_env_ios

## Print status messages to console
clear
echo -e "\n=== Connecting to IOS-XR mgmt interface:" ${CYAN} $xr_mgmt ${RESTORE}"started at" ${YELLOW} $(date) ${RESTORE} "===\n"

## Use for loop to apply config for Tunnels, dummy static routes and static mpls paths
./create-tun-txt.sh

##Create BGP inbound and outbound policies
##./create-bgp.sh

##Create VRF config
##./create-vrf.sh $2

## Check BGP neighbor state
##./check-bgp-state.sh

echo -e ${RESTORE} '\n' "=== All Config tasks completed" ${YELLOW} $(date) ${RESTORE}"===\n"
