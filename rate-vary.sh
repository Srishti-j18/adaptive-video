iface=$(ifconfig | grep -B1 "inet 192.168.0.1" | head -n1 | cut -f1 -d:)

sudo tc qdisc del dev $iface root  
sudo tc qdisc add dev $iface root handle 1: htb default 3  
sudo tc class add dev $iface parent 1: classid 1:3 htb rate 10Mbit  
sudo tc qdisc add dev $iface parent 1:3 handle 3: pfifo limit 100

scale="$2"
f="$1"
while true; do
tail -n +2 "$f" | tr -d '\r' | while IFS=, read -r tput u
do
        unit=$(echo "$u" | cut -d's' -f1)
        if [ "$tput" = "0" ] ; then
                tput=1
        fi
        tputScaled=$(expr $scale*$tput | bc)
        echo "$tputScaled $unit/second"
        cmd="sudo tc class replace dev $iface parent 1: classid 1:3 htb rate ${tputScaled}${unit}"
        eval "$cmd"
        sleep 1
done
done
