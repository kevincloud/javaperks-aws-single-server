#!/bin/bash
# Configures the Consul server

echo "Installing Consul..."
curl -sfLo "consul.zip" "${CONSUL_URL}"
sudo unzip consul.zip -d /usr/local/bin/
rm -rf consul.zip

export CONSUL_KEY=`consul keygen`
export CONSUL_TOKEN=`uuidgen`

echo "Add Consul user..."
groupadd consul
useradd consul -g consul

# Server configuration
sudo bash -c "cat >/etc/consul.d/consul-server.json" <<EOF
{
    "data_dir": "/opt/consul",
    "datacenter": "${REGION}",
    "node_name": "consul-server",
    "client_addr": "0.0.0.0",
    "bind_addr": "0.0.0.0",
    "advertise_addr": "${CLIENT_IP}",
    "domain": "consul",
    "acl_enforce_version_8": false,
    "server": true,
    "bootstrap_expect": 1,
    "retry_join": ["provider=aws tag_key=${CONSUL_JOIN_KEY} tag_value=${CONSUL_JOIN_VALUE}"],
    "ui": true,
    "recursors": ["169.254.169.253"],
    "encrypt": "$CONSUL_KEY",
    "acl_datacenter": "${REGION}",
    "acl_down_policy": "extend-cache",
    "acl_default_policy": "allow",
    "acl_down_policy": "allow",
    "acl_master_token": "$CONSUL_TOKEN",
    "connect": {
        "enabled": true
    }
}
EOF

# Set Consul up as a systemd service
echo "Installing systemd service for Consul..."
sudo bash -c "cat >/etc/systemd/system/consul.service" <<EOF
[Unit]
Description=Hashicorp Consul
Requires=network-online.target
After=network-online.target

[Service]
User=consul
Group=consul
PIDFile=/var/run/consul/consul.pid
PermissionsStartOnly=true
ExecStart=/usr/local/bin/consul agent -config-file=/etc/consul.d/consul-server.json -pid-file=/var/run/consul/consul.pid
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
EOF

echo "Update Consul permissions..."
chown -R consul:consul /usr/local/bin/consul
chown -R consul:consul /etc/consul.d/
chown -R consul:consul /opt/consul/
chown -R consul:consul /var/run/consul/

echo "Start service..."
sudo systemctl start consul
sudo systemctl enable consul

echo "Configure Consul name resolution..."
systemctl disable systemd-resolved
systemctl stop systemd-resolved
ls -lh /etc/resolv.conf
rm /etc/resolv.conf
echo "nameserver 127.0.0.1" > /etc/resolv.conf
netplan apply

sudo bash -c "cat >>/etc/dnsmasq.conf" <<EOF
server=/consul/${CLIENT_IP}#8600
server=169.254.169.253#53
listen-address=${CLIENT_IP}
listen-address=127.0.0.1
listen-address=169.254.1.1
no-resolv
log-queries
EOF

ip link add dummy0 type dummy
ip link set dev dummy0 up
ip addr add 169.254.1.1/32 dev dummy0
ip link set dev dummy0 up

sudo bash -c "cat >>/etc/systemd/network/dummy0.netdev" <<EOF
[NetDev]
Name=dummy0
Kind=dummy
EOF

sudo bash -c "cat >>/etc/systemd/network/dummy0.network" <<EOF
[Match]
Name=dummy0

[Network]
Address=169.254.1.1/32
EOF

systemctl restart systemd-networkd
systemctl stop dnsmasq
systemctl start dnsmasq
service consul stop
service consul start

sleep 3

echo "Get Consul node id..."
export CONSUL_NODE_ID=$(curl -s http://127.0.0.1:8500/v1/catalog/node/consul-server | jq -r .Node.ID)

# register the database host with consul
echo "Registering customer-db with consul..."
echo "{ \"Datacenter\": \"$REGION\", \"Node\": \"$CONSUL_NODE_ID\", \"Address\":\"$MYSQL_HOST\", \"Service\": { \"ID\": \"customer-db\", \"Service\": \"customer-db\", \"Address\": \"$MYSQL_HOST\", \"Port\": 3306 } }"
curl \
    --request PUT \
    --data "{ \"Datacenter\": \"$REGION\", \"Node\": \"$CONSUL_NODE_ID\", \"Address\":\"$MYSQL_HOST\", \"Service\": { \"ID\": \"customer-db\", \"Service\": \"customer-db\", \"Address\": \"$MYSQL_HOST\", \"Port\": 3306 } }" \
    http://127.0.0.1:8500/v1/catalog/register

