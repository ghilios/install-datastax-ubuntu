#!/usr/bin/env bash

node_ip=$1
node_broadcast_ip=$2
seed_node_public_ip=$3
cloud_type=$4
dcos_container_path=$5

echo in configure_cassandra_yaml cloud_type = $cloud_type

seeds=$seed_node_public_ip
listen_address=$node_ip
broadcast_address=$node_broadcast_ip
rpc_address="0.0.0.0"
broadcast_rpc_address=$node_broadcast_ip

endpoint_snitch="GossipingPropertyFileSnitch"

data_file_directories="$dcos_container_path/data"
commitlog_directory="$dcos_container_path/commitlog"
saved_caches_directory="$dcos_container_path/saved_caches"


phi_convict_threshold=12
auto_bootstrap="false"

file=/etc/dse/cassandra/cassandra.yaml

date=$(date +%F)
backup="$file.$date"
cp $file $backup

cat $file \
| sed -e "s:\(.*- *seeds\:\).*:\1 \"$seeds\":" \
| sed -e "s:^\(listen_address\:\).*:listen_address\: $listen_address:" \
| sed -e "s:^\(broadcast_address\:\).*:broadcast_address\: $broadcast_address:" \
| sed -e "s:^\(rpc_address\:\).*:rpc_address\: $rpc_address:" \
| sed -e "s:^\(broadcast_rpc_address\:\).*:broadcast_rpc_address\: $broadcast_rpc_address:" \
| sed -e "s:^\(endpoint_snitch\:\).*:endpoint_snitch\: $endpoint_snitch:" \
| sed -e "s:\(.*- \)/var/lib/cassandra/data.*:\1$data_file_directories:" \
| sed -e "s:^\(commitlog_directory\:\).*:commitlog_directory\: $commitlog_directory:" \
| sed -e "s:^\(saved_caches_directory\:\).*:saved_caches_directory\: $saved_caches_directory:" \
| sed -e "s:^\(phi_convict_threshold\:\).*:phi_convict_threshold\: $phi_convict_threshold:" \
> $file.new

echo "auto_bootstrap: $auto_bootstrap" >> $file.new
echo "" >> $file.new

mv $file.new $file

# Owner was ending up as root which caused the backup service to fail
chown cassandra $file
chgrp cassandra $file

# Change dse-data directory's ownership to cassandra
chown cassandra $dcos_container_path
chgrp cassandra $dcos_container_path
