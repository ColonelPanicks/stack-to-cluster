Notes on setting up a "group of nodes" for testing configuration with.

- Create VPC, subnet and internet gateway in AWS
- Create security group that allows external SSH & all traffic between subnet
- Launch 3 EC2 instances from generic CentOS 7 image in VPC (only one with pub IP - disable Source/Dest check on interface)
- Setup IP forwarding on the node with a public IP 
```
firewall-cmd --add-rich-rule='rule family="ipv4" source address="10.0.0.0/255.255.0.0" masquerade' --permanent
firewall-cmd --reload

echo 1 > /proc/sys/net/ipv4/ip_forward
```
- Add default route to nodes by making sure following settings in `/etc/sysconfig/network-scripts/ifcfg-eth0` and then doing `systemctl restart network`
```
NM_CONTROLLED=no
GATEWAY=IP_OF_NODE_WITH_PUB_IP
PEERDNS=yes
PEERROUTES=no
ZONE=trusted
DNS1=10.0.0.2
```
- Setup `/etc/hosts` to have all 3 nodes in
- NFS master setup (as root)
```
yum install nfs-utils

mkdir /share
chmod 777 /share

cat << EOF > /etc/exports
/home   *(rw,no_root_squash)
/share  *(rw,no_root_squash)
EOF

systemctl enable nfs-server
systemctl start nfs-server

exportfs -va

firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service=mountd
firewall-cmd --permanent --add-service=rpc-bind
firewall-cmd --reload
```
- NFS slave setup (as root)
```
yum install nfs-utils

mkdir /share
chmod 777 /share

cat << EOF >> /etc/fstab
stack1:/home    /home   nfs intr,rsize=32768,wsize=32768,vers=3,_netdev,nofail  0 0
stack1:/share   /share   nfs intr,rsize=32768,wsize=32768,vers=3,_netdev,nofail  0 0
EOF

systemctl enable nfs
systemctl start nfs

mount -a
```
