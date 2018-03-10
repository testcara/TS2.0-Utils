#!/bin/sh
echo "==installing the pub qa tools=="
echo "yum install -y dockpulp rh-dockpulp"
yum install -y dockpulp rh-dockpulp
echo "==writing the /etc/dockerpulp.conf=="
vim -c ":1,$ d" -c ":wq" /etc/dockpulp.conf
echo "
[pulps]
test = https://pulp-docker-wlin.usersys.redhat.com
 
[registries]
test = https://pulp-docker-wlin.usersys.redhat.com:8888
 
[filers]
test = http://10.73.67.150
 
[verify]
test = no
 
[redirect]
test = no
 
[distributors]
test = docker_web_distributor_name_cli,cdn_distributor,cdn_distributor_unprotected
 
[release_order]
test = cdn_distributor_no_extra,cdn_distributor_unprotected_no_extra,docker_web_distributor_name_cli,cdn_distributor_unprotected_no_content,cdn_distributor_no_content
 
[chunk_size]
test = 10
 
[timeout]
test = 5000
" >> /etc/dockpulp.conf
echo "==Outputting the dockerpulp.conf files"
cat /etc/dockerpulp.conf
echo "==creating some repos=="
echo "dock-pulp -s test login -u admin -p admin"
dock-pulp -s test login -u admin -p admin
for  item  in   rhel7.3  rhel   rhel7  rhel7-rhel
do
echo "dock-pulp -s test create --library  ${item}"
dock-pulp -s test create --library  ${item}
done
