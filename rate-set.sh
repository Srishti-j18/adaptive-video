addr=$(dig +short @127.0.0.53 romeo)
iface=$(ip route get "$addr" | grep -oP "(?<=dev )[^ ]+")

sudo tc qdisc del dev $iface root  
sudo tc qdisc add dev $iface root handle 1: htb default 3  
sudo tc class add dev $iface parent 1: classid 1:3 htb rate $1  
sudo tc qdisc add dev $iface parent 1:3 handle 3: pfifo limit 100
