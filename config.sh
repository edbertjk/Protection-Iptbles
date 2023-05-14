echo "ESP METHOD HANDLE~~~"
iptables -A INPUT -p esp -j DROP

echo "ICMP METHOD HANDLE~~~"
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

echo "PRI METHOD HANDLE~~~"
iptables -A INPUT -p tcp --dport 443 -m string --string "GET" --algo bm -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m string --string "POST" --algo bm -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m string --string "PRI" --algo bm --to 65535 -j DROP

echo "UDP FLOOD HANDLE~~~"
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
iptables -t raw -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
iptables -t raw -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
iptables -t raw -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -t raw -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
iptables -t raw -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
iptables -t raw -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
iptables -t raw -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP
iptables -t raw -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
iptables -t raw -A PREROUTING -p tcp --tcp-flags ALL ALL -m comment --comment "xmas pkts (xmas portscanners)" -j DROP
iptables -t raw -A PREROUTING -p tcp --tcp-flags ALL NONE -m comment --comment "null pkts (null portscanners)" -j DROP
iptables -t raw -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
iptables -t raw -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP
iptables -t raw -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
iptables -A INPUT -p udp -m hashlimit --hashlimit-above 10/sec --hashlimit-mode srcip --hashlimit-name UDP-FLOOD -j DROP
iptables -A INPUT -m hashlimit --hashlimit-above 30/sec --hashlimit-mode srcip --hashlimit-name COMBINED-FLOOD -j DROP
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