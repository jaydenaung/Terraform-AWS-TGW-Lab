#!/bin/bash
set -eux

# Wait for cloud-init networking, then install net-tools
until sudo apt-get update; do
    sleep 2
done
sudo apt-get install -y net-tools iptables

# Configure the secondary interface (internal-facing).
# On t2.* (Xen) instances the interfaces are eth0 / eth1.
ifconfig eth1 10.7.1.10/24 up
ip route add 10.0.0.0/8 via 10.7.1.1 dev eth1 || true

# Enable IP forwarding (persistent + immediate)
echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-ipforward.conf
sudo sysctl -w net.ipv4.ip_forward=1

# Forwarding rules between internal (eth1) and external (eth0)
iptables -A FORWARD -o eth0 -i eth1 -s 10.0.0.0/8 -m conntrack --ctstate NEW -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Inbound DNAT for web servers (port forwarding via the NAT instance)
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80   -j DNAT --to 10.7.5.20:80
iptables -A FORWARD -p tcp -d 10.7.5.20 --dport 80 -j ACCEPT
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 8081 -j DNAT --to 10.10.1.20:80
iptables -A FORWARD -p tcp -d 10.10.1.20 --dport 80 -j ACCEPT
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 8082 -j DNAT --to 10.20.1.20:80
iptables -A FORWARD -p tcp -d 10.20.1.20 --dport 80 -j ACCEPT

# Friendly hostnames for SSH-from-NAT testing
echo "10.7.5.20       web1"        | sudo tee -a /etc/hosts
echo "10.10.1.20      spoke1-web1" | sudo tee -a /etc/hosts
echo "10.20.1.20      spoke2-web1" | sudo tee -a /etc/hosts
