import sys, ipaddress; 
nets=list(ipaddress.ip_network(u'172.20.0.0/16').subnets(prefixlen_diff=8))
print(nets[10])
##for p in nets:
##  print(p)
