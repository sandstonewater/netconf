#!/usr/bin/python

from ncclient import manager

with manager.connect(host="192.168.0.8", port=830, username="root", password="root", hostkey_verify=False) as nc_conn:
   nc_config = nc_conn.get_config(source='running').data_xml
   print nc_config
