#!/bin/bash

read -p "Cluster name: " clustername
read -p "Shared data storage dir: " storagedir
read -p "Node list (space separated): " nodes

# Variables
topdir=$storagedir/openflighthpc
packagedir=$topdir/packages

# Prep
sudo mkdir -p $packagedir
sudo chmod 777 $packagedir

# Download user-suite packages
sudo yum install -y https://repo.openflighthpc.org/pub/centos/7/openflighthpc-release-latest.noarch.rpm
yumdownloader --destdir=$packagedir --resolve -y flight-user-suite

# Install & configure this node
sudo yum install -y $packagedir/*.rpm
/opt/flight/bin/flight config set cluster.name $clustername

# Install & configure compute nodes
for node in $nodes ; do 
    ssh $node "sudo yum install -y $packagedir/*.rpm"
    ssh $node "/opt/flight/bin/flight config set cluster.name $clustername"
done


