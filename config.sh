echo "ICMP METHOD HANDLE~~~"
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

echo "PRI METHOD HANDLE~~~"
iptables -A INPUT -p tcp --dport 443 -m string --string "PRI" --algo bm --to 65535 -j DROP

echo "UDP FLOOD HANDLE~~~"
iptables -A INPUT -p udp -m hashlimit --hashlimit-name udpflood --hashlimit-above 10/s --hashlimit-mode srcip --hashlimit-burst 20 --hashlimit-htable-expire 60000 -j DROP
iptables -A INPUT -p udp --syn -m limit --limit 5/s -j ACCEPT
iptables -A INPUT -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p udp -j DROP

echo "COUNTRY HANDLE~~~"

cat azure | xargs -I {} sudo iptables -A INPUT -s {} -j DROP
cat linode | xargs -I {} sudo iptables -A INPUT -s {} -j DROP
cat country | xargs -I {} sudo iptables -A INPUT -s {} -j ACCEPT

echo "LAST HANDLE~~~"
iptables -A INPUT -j DROP

268581