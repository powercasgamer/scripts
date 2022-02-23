#!/bin/bash

output(){
    echo -e '\e[34m'$1'\e[0m';
}

exitOut() {
    ufw reload
    output "Exiting"
    exit 1
}

get_ports(){
    output "Enter the list of ports you want opened, separated by a space."
    output "For example, if you want to open port 25565-25570, type: "
    output "25565 25566 25567 25568 25569 25570"
    read -a ports

    if [ $ports = "" ]; then
      output "You cannot put in an empty list of ports! Try again:"
      get_ports
    fi
}

get_service() {
    output "Enter the service you want to use"
    output "Options are: cloudflare, tcpshield, custom or common"
    read -a service

    if [ $service = "" ]; then
      output "You cannot have an empty service! Try again:"
      get_service
    fi
}

tcpshield() {
    get_ports
    ufw allow 22 comment "SSH"
    wget https://tcpshield.com/v4
     
    for ips in `cat v4`;
    do
       for port in "${ports[@]}";
       do
         ufw allow from $ips to any proto tcp port $port comment "TCPShield"
       done
    done    
    yes | ufw enable

    rm v4

    exitOut
    output "TCPShield IPs have been whitelisted on your selected ports!"
}

cloudflare() {
    get_ports
     ufw allow 22 comment "SSH"
     wget https://www.cloudflare.com/ips-v4
     wget https://www.cloudflare.com/ips-v6
     
     for ips in `cat ips-v4`;
     do
        for port in "${ports[@]}";
        do
            ufw allow from $ips to any proto tcp port $port comment "Cloudflare"
            ufw allow from $ips to any proto udp port $port comment "Cloudflare"
        done
     done
     
     for ips in `cat ips-v6`;
     do
        for port in "${ports[@]}";
        do
            ufw allow from $ips to any proto tcp port $port comment "Cloudflare"
            ufw allow from $ips to any proto udp port $port comment "Cloudflare"
        done
     done
     
     yes | ufw enable

     rm ips-v4
    rm ips-v6
    exitOut

    output "Cloudflare IPs have been whitelisted on your selected ports!"
}

common() {
    ufw default deny incoming
    ufw allow 22/tcp comment "SSH"
    ufw allow 443/tcp comment "HTTPS"
    ufw allow 80/tcp comment "HTTP"
    ufw allow 9418/tcp comment "Git"
    ufw allow 123/udp comment "NTP"
    ufw allow 53 comment "DNS"

    output "Added common ports to UFW"
    exitOut
}

custom() {
    get_ports

    for port in "${ports[@]}";
        do
            ufw allow $port comment "Custom"
        done
    exitOut
}

delete() {
    output "Enter the rule with a comment you want to delete"
    output "Examples: TCPShield, Cloudflare, Banned IP"
    read -a comment

    if [ $comment = "" ]; then
      output "You cannot put in an empty list of ports! Try again:"
      delete
    fi

    for NUM in $(ufw status numbered | grep ${comment} | awk -F"[][]" '{print $2}' | tr --delete [:blank:] | sort -rn); do
        #output "$NUM"
        ufw --force delete $NUM
        output "Deleted $NUM"
    done
    exitOut

    #rule=$(/usr/sbin/ufw status | grep " $comment")
    #output $rule
    #if [ -n "$rule" ]; then
    #  /usr/sbin/ufw delete $rule
    #  output "rule deleted to any"
    #else
    #  output "rule does not exist. nothing to do."
    #fi
}

get_service

if [ $service == "tcpshield" ]; then
    tcpshield
elif  [ $service == "cloudflare" ]; then
    cloudflare
elif  [ $service == "custom" ]; then
    custom
elif  [ $service == "common" ]; then
    common
elif [ $service == "delete" ]; then
    delete
else 
    exitOut
fi

