iface=$(ifconfig | grep -B1 "inet 192.168.0.1" | head -n1 | cut -f1 -d:)

sudo tc qdisc del dev $iface root  
sudo tc qdisc add dev $iface root handle 1: htb default 3  
sudo tc class add dev $iface parent 1: classid 1:3 htb rate $1  
sudo tc qdisc add dev $iface parent 1:3 handle 3: pfifo limit 100
