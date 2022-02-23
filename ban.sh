#!/bin/bash

#sed ips.txt | while read line
#do
#    sudo ufw insert 1 deny from $ip to any comment "Banned IP"
#    output "Blocking $line"
#done

output(){
    echo -e '\e[34m'$1'\e[0m';
}


add_rule() {
  ip=$1
  #regex=" Banned IP"
  #rule=$(ufw status numbered | grep $regex)
  #output $rule
  #if [ -z "$rule" ]; then
      /usr/sbin/ufw insert 1 deny from ${ip} to any comment "Banned IP"
  #    output "rule does not exist. Added $ip deny list"
  #else
  #    output "rule already exists. nothing to do."
  #fi
}

#for line in 'cat ips.txt'; 
#do
#  output "Test"
#  #add_rule $line
#done

while read line; do add_rule $line; done < ips.txt

# 
#delete_rule() {
#  local ip=$1
#  local regex=" Banned IP"
#  local rule=$(/usr/sbin/ufw status numbered | grep $regex)
#  if [ -n "$rule" ]; then
#      /usr/sbin/ufw delete deny from ${ip} to any comment "Banned IP"
#      output "${start} rule deleted ${ip} to any"
#  else
#      output "${start} rule does not exist. nothing to do."
#  fi
#}

#sed ips.txt | while read line
#do
#    output $line
#    add_rule $line
#done