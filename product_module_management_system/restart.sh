#!/bin/bash

ps alx | grep product_module_management_system.py | grep -v grep | gawk '{ print $3 }' | xargs kill
sleep 1
cd /product_module_management_system
./product_module_management_system.py >> /var/log/product-release/product_module_management_system.log 2>&1 &

 
