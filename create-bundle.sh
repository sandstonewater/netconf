#!/bin/bash
#!/usr/bin/python

export RESTORE='\033[0m'
export YELLOW='\033[00;33m'
export CYAN='\033[00;36m'
export RED=$(tput setaf 1)
export WHITE=$(tput setaf 7)
export GREEN=$(tput setaf 2)

. $1

## Print table headers for tunnel details
clear
echo -e '\n'"--- Building" $BUNDLE_NAME "...\n"
##cat $1

echo -e "\nCreating" $BUNDLE_NAME "in Router 1..."
python ncc.py --host $xr_mgmt1 --port $xr_port1 -u $xr_user -p $xr_pass --do-edits dc-bundle --params '{"INT_NAME":"'$BUNDLE_NAME'","INT_DESC":"'$BUNDLE_DESC'"}'
echo -e "Creating" $BUNDLE_NAME "in Router 2..."
python ncc.py --host $xr_mgmt2 --port $xr_port2 -u $xr_user -p $xr_pass --do-edits dc-bundle --params '{"INT_NAME":"'$BUNDLE_NAME'","INT_DESC":"'$BUNDLE_DESC'"}'

for i in ${arr_Bundle_Members[@]}
do
  echo -e "\nAdding interface" $i "to bundle in R1"
  python ncc.py --host $xr_mgmt1 --port $xr_port1 -u $xr_user -p $xr_pass --do-edits dc-bundle-member --params '{"INT_NAME":"'$i'","INT_DESC":"'$INT_DESC'","BUNDLE_ID":"'$BUNDLE_ID'"}'
  ./check-interface.sh $xr_mgmt1 $xr_user $xr_pass $i $xr_port1
  echo -e "Adding interface" $i "to bundle in R2"
  python ncc.py --host $xr_mgmt2 --port $xr_port2 -u $xr_user -p $xr_pass --do-edits dc-bundle-member --params '{"INT_NAME":"'$i'","INT_DESC":"'$INT_DESC'","BUNDLE_ID":"'$BUNDLE_ID'"}'
  ./check-interface.sh $xr_mgmt2 $xr_user $xr_pass $i $xr_port2
done
echo -e '\n'"--- Finished creating" $BUNDLE_NAME  "---\n"
