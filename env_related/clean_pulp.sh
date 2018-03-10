#!/bin/sh
echo "== clean the rpm & metadata files =="
echo 'find . -name "*.rpm" | xargs rm -rf'
find . -name "*.rpm" | xargs rm -rf
echo 'find . -name "*.xml.gz" | xargs rm -rf'
find . -name "*.xml.gz" | xargs rm -rf 
echo 'rm -rf /var/lib/pulp/published/yum/*'
rm -rf /var/lib/pulp/published/yum/*
echo "== clean the dirty data in mongodb ==" 
ipaddr=$(ifconfig | grep "inet addr" | grep "Bcast:10"| cut -d ":" -f 2| sed "s/Bcast//"| tr -d " ")
mongo ${ipaddr}:27017 < test.js 
echo "== clean end =="
