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
iptables -A INPUT -p tcp --tcp-flags ALL ACK -m tcp --tcp-option 34 -m limit --limit 1/s --limit-burst 5 -j ACCEPT
iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j DROP
iptables -A INPUT -p tcp --syn -m hashlimit --hashlimit-above 2/sec --hashlimit-mode srcip --hashlimit-srcmask 32 --hashlimit-name syn-limits -j DROP
iptables -A INPUT -p tcp --syn -m connlimit --connlimit-above 10 --connlimit-mask 32 --connlimit-saddr -j DROP
iptables -A INPUT -p udp -m u32 --u32 "0>>22&0x3C@12&0xFFFF0000=0x55534450" -j DROP
sudo iptables -A INPUT -p tcp --syn -m u32 --u32 "0>>22&0x3C@12&0xFFFF0000=0x53544F52" -j DROP
iptables -A INPUT -p udp -m hashlimit --hashlimit-above 10/sec --hashlimit-mode srcip --hashlimit-name UDP-FLOOD -j DROP
iptables -A INPUT -m hashlimit --hashlimit-above 30/sec --hashlimit-mode srcip --hashlimit-name COMBINED-FLOOD -j DROP
iptables -A INPUT -p udp -m hashlimit --hashlimit-name udpflood --hashlimit-above 10/s --hashlimit-mode srcip --hashlimit-burst 20 --hashlimit-htable-expire 60000 -j DROP
iptables -A INPUT -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p udp -j DROP

echo "COUNTRY HANDLE~~~"

cat azure | xargs -I {} sudo iptables -A INPUT -s {} -j DROP
cat linode | xargs -I {} sudo iptables -A INPUT -s {} -j DROP
cat country | xargs -I {} sudo iptables -A INPUT -s {} -j ACCEPT

echo "LAST HANDLE~~~"
iptables -A INPUT -j DROP