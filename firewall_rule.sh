#!/bin/sh

complete=false

while ! $complete; do
        echo "Enter the rule details below, if an option doesn't apply leave it blank"
        echo "Name: "
        read -r name
        echo "Source: "
        read -r src
        echo "Destination: "
        read -r dest
        echo "Protocol: "
        read -r proto
        echo "Target: "
        read -r target
        echo "Family: "
        read -r family
        echo "IP source: "
        read -r src_ip
        echo "Destination port: "
        read -r dest_port

        uci add firewall rule
        if  [ -n "$name" ]; then uci set firewall.@rule[-1].name="$name"; fi
        if  [ -n "$src" ]; then uci set firewall.@rule[-1].src="$src"; fi
        if  [ -n "$dest" ]; then uci set firewall.@rule[-1].dest="$dest"; fi
        if  [ -n "$proto" ]; then uci set firewall.@rule[-1].proto="$proto"; fi
        if  [ -n "$target" ]; then uci set firewall.@rule[-1].target="$target"; fi
        if  [ -n "$family" ]; then uci set firewall.@rule[-1].family="$family"; fi
        if  [ -n "$src_ip" ]; then uci set firewall.@rule[-1].src_ip="$src_ip"; fi
        if  [ -n "$dest_port" ]; then uci set firewall.@rule[-1].dest_port="$dest_port"; fi
        uci set firewall.@rule[-1].enabled="1"
        uci commit firewall

        echo "Do you want to add another rule? (y/n)"
        read -r continue
        if [ "$continue" = "n" ]
        then
                continue=true
                break
        fi
done
echo "Run 'service firewall restart' when you are finished"
