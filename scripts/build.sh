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
    "acl_datacenter": "us-east-1",
    "acl_down_policy": "extend-cache",
    "acl_default_policy": "allow",
    "acl_down_policy": "allow",
    "acl_master_token": "$CONSUL_TOKEN"
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
ExecReload=/bin/kill -HUP $MAINPID
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

# Configure the load balancer for "product-api"
sudo bash -c "cat >>/etc/nginx/conf.d/lb-product-api.conf.ctmpl" <<EOF
upstream backend {
{{ range service "product-api" }}
    server {{ .Address }}:{{ .Port }};
{{ end }}
}

server {
   listen 5821;

   location / {
      proxy_pass                  http://backend;
   }
}
EOF

# Configure the load balancer for "cart-api"
sudo bash -c "cat >>/etc/nginx/conf.d/lb-cart-api.conf.ctmpl" <<EOF
upstream backend {
{{ range service "cart-api" }}
    server {{ .Address }}:{{ .Port }};
{{ end }}
}

server {
   listen 5823;

   location / {
      proxy_pass                  http://backend;
   }
}
EOF

# Configure the load balancer for "order-api"
sudo bash -c "cat >>/etc/nginx/conf.d/lb-order-api.conf.ctmpl" <<EOF
upstream backend {
{{ range service "order-api" }}
    server {{ .Address }}:{{ .Port }};
{{ end }}
}

server {
   listen 5826;

   location / {
      proxy_pass                  http://backend;
   }
}
EOF

# remove default website files from nginx
rm -rf /etc/nginx/sites-enabled/*
service nginx reload

echo "Installing Consul Template..."

curl -sfLo "consul-template.zip" "${CTEMPLATE_URL}"
sudo unzip consul-template.zip -d /usr/local/bin/

sudo bash -c "cat >>/etc/consul.d/consul-template-config.hcl" <<EOF
consul {
    address = "${CLIENT_IP}:8500"

    retry {
        enabled = true
        attempts = 12
        backoff = "250ms"
    }

    ssl {
        enabled = false
        verify = false
    }
}

vault {
    address = "http://vault-main.service.${REGION}.consul:8200/"
    token = "${VAULT_TOKEN}"
    renew_token = false
}

template {
    source      = "/etc/nginx/conf.d/lb-product-api.conf.ctmpl"
    destination = "/etc/nginx/conf.d/lb-product-api.conf"
    perms = 0600
    command = "service nginx reload"
}

template {
    source      = "/etc/nginx/conf.d/lb-cart-api.conf.ctmpl"
    destination = "/etc/nginx/conf.d/lb-cart-api.conf"
    perms = 0600
    command = "service nginx reload"
}

template {
    source      = "/etc/nginx/conf.d/lb-order-api.conf.ctmpl"
    destination = "/etc/nginx/conf.d/lb-order-api.conf"
    perms = 0600
    command = "service nginx reload"
}

# template {
#     source      = "/etc/nginx/conf.d/lb-auth-api.conf.ctmpl"
#     destination = "/etc/nginx/conf.d/lb-auth-api.conf"
#     perms = 0600
#     command = "service nginx reload"
# }
EOF

# Set Consul Template up as a systemd service
echo "Installing systemd service for Consul..."
sudo bash -c "cat >/etc/systemd/system/consul-template.service" <<EOF
[Unit]
Description=Hashicorp Consul Template
Requires=network-online.target
After=network-online.target

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul-template -config=/etc/consul.d/consul-template-config.hcl -pid-file=/var/run/consul/consul-template.pid
SuccessExitStatus=12
ExecReload=/bin/kill -SIGHUP $MAINPID
ExecStop=/bin/kill -SIGINT $MAINPID
KillMode=process
Restart=always
RestartSec=42s
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

chown -R consul:consul /etc/nginx/conf.d

echo "Start service..."
sudo systemctl enable consul-template
sudo systemctl start consul-template

echo "Consul installation complete."

# Configures the Vault server for a database secrets demo

echo "Installing Vault..."
curl -sfLo "vault.zip" "${VAULT_URL}"
sudo unzip vault.zip -d /usr/local/bin/
rm -rf vault.zip

# Server configuration
sudo bash -c "cat >/etc/vault.d/vault.hcl" <<EOF
storage "file" {
  path = "/opt/vault"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

seal "awskms" {
    region = "${REGION}"
    kms_key_id = "${AWS_KMS_KEY_ID}"
}

ui = true
EOF

# Set Vault up as a systemd service
echo "Installing systemd service for Vault..."
sudo bash -c "cat >/etc/systemd/system/vault.service" <<EOF
[Unit]
Description=Hashicorp Vault
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
Restart=on-failure # or always, on-abort, etc

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl start vault
sudo systemctl enable vault

sleep 5

echo "Initializing and setting up environment variables..."
export VAULT_ADDR=http://localhost:8200

vault operator init -recovery-shares=1 -recovery-threshold=1 -key-shares=1 -key-threshold=1 > /root/init.txt 2>&1

sleep 10

echo "Extracting vault root token..."
export VAULT_TOKEN=$(cat /root/init.txt | sed -n -e '/^Initial Root Token/ s/.*\: *//p')
echo "Root token is $VAULT_TOKEN"
consul kv put service/vault/root-token $VAULT_TOKEN
echo "Extracting vault recovery key..."
export RECOVERY_KEY=$(cat /root/init.txt | sed -n -e '/^Recovery Key 1/ s/.*\: *//p')
echo "Recovery key is $RECOVERY_KEY"
consul kv put service/vault/recovery-key $RECOVERY_KEY

echo "export VAULT_ADDR=http://localhost:8200" >> /home/ubuntu/.profile
echo "export VAULT_TOKEN=$(consul kv get service/vault/root-token)" >> /home/ubuntu/.profile
echo "export VAULT_ADDR=http://localhost:8200" >> /root/.profile
echo "export VAULT_TOKEN=$(consul kv get service/vault/root-token)" >> /root/.profile

sudo bash -c "cat >/etc/vault.d/nomad-policy.json" <<EOF
{
    "policy": "# Allow creating tokens under \"nomad-cluster\" token role. The token role name\n# should be updated if \"nomad-cluster\" is not used.\npath \"auth/token/create/nomad-cluster\" {\n  capabilities = [\"update\"]\n}\n\n# Allow looking up \"nomad-cluster\" token role. The token role name should be\n# updated if \"nomad-cluster\" is not used.\npath \"auth/token/roles/nomad-cluster\" {\n  capabilities = [\"read\"]\n}\n\n# Allow looking up the token passed to Nomad to validate # the token has the\n# proper capabilities. This is provided by the \"default\" policy.\npath \"auth/token/lookup-self\" {\n  capabilities = [\"read\"]\n}\n\n# Allow looking up incoming tokens to validate they have permissions to access\n# the tokens they are requesting. This is only required if\n# 'allow_unauthenticated' is set to false.\npath \"auth/token/lookup\" {\n  capabilities = [\"update\"]\n}\n\n# Allow revoking tokens that should no longer exist. This allows revoking\n# tokens for dead tasks.\npath \"auth/token/revoke-accessor\" {\n  capabilities = [\"update\"]\n}\n\n# Allow checking the capabilities of our own token. This is used to validate the\n# token upon startup.\npath \"sys/capabilities-self\" {\n  capabilities = [\"update\"]\n}\n\n# Allow our own token to be renewed.\npath \"auth/token/renew-self\" {\n  capabilities = [\"update\"]\n}\n"
}
EOF

sudo bash -c "cat >/etc/vault.d/access-creds.json" <<EOF
{
    "policy": "path \"secret/data/aws\" {\n  capabilities = [\"read\", \"list\"]\n}\n\npath \"secret/data/roottoken\" {\n  capabilities = [\"read\", \"list\"]\n}\n\npath \"custdbcreds/creds/cust-api-role\" {\n    capabilities = [\"list\", \"read\"]\n}\n"
}
EOF

sudo bash -c "cat >/etc/vault.d/nomad-cluster-role.json" <<EOF
{
    "disallowed_policies": "nomad-server",
    "explicit_max_ttl": 0,
    "name": "nomad-cluster",
    "orphan": true,
    "period": 259200,
    "renewable": true
}
EOF

echo "Configuring Vault..."

# Enable auditing
curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request PUT \
    --data "{ \"descriptiopn\": \"Primary Audit\", \"type\": \"file\", \"options\": { \"file_path\": \"/var/log/vault/log\" } }" \
    http://127.0.0.1:8200/v1/sys/audit/main-audit

# Enable dynamic database creds
curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data '{"type": "database" }' \
    http://127.0.0.1:8200/v1/sys/mounts/custdbcreds

# Configure connection
curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data "{ \"plugin_name\": \"mysql-database-plugin\", \"allowed_roles\": \"cust-api-role\", \"connection_url\": \"{{username}}:{{password}}@tcp($MYSQL_HOST:3306)/\", \"username\": \"$MYSQL_USER\", \"password\": \"$MYSQL_PASS\" }" \
    http://127.0.0.1:8200/v1/custdbcreds/config/custapidb

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data "{ \"db_name\": \"custapidb\", \"creation_statements\": \"CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; GRANT ALL PRIVILEGES ON $MYSQL_DB.* TO '{{name}}'@'%';\", \"default_ttl\": \"5m\", \"max_ttl\": \"24h\" }" \
    http://127.0.0.1:8200/v1/custdbcreds/roles/cust-api-role

# Enable secrets mount point for kv2
curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data '{"type": "kv", "options": { "version": "2" } }' \
    http://127.0.0.1:8200/v1/sys/mounts/usercreds

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data '{"type": "kv", "options": { "version": "2" } }' \
    http://127.0.0.1:8200/v1/sys/mounts/secret

# add usernames and passwords

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data '{"data": { "username": "jthomp4423@example.com", "password": "SuperSecret1", "customerno": "CS100312" } }' \
    http://127.0.0.1:8200/v1/usercreds/data/jthomp4423@example.com

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data '{"data": { "username": "wilson@example.com", "password": "SuperSecret1", "customerno": "CS106004" } }' \
    http://127.0.0.1:8200/v1/usercreds/data/wilson@example.com

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data '{"data": { "username": "tommy6677@example.com", "password": "SuperSecret1", "customerno": "CS101438" } }' \
    http://127.0.0.1:8200/v1/usercreds/data/tommy6677@example.com

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data '{"data": { "username": "mmccann1212@example.com", "password": "SuperSecret1", "customerno": "CS210895" } }' \
    http://127.0.0.1:8200/v1/usercreds/data/mmccann1212@example.com

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data '{"data": { "username": "cjpcomp@example.com", "password": "SuperSecret1", "customerno": "CS122955" } }' \
    http://127.0.0.1:8200/v1/usercreds/data/cjpcomp@example.com

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data '{"data": { "username": "jjhome7823@example.com", "password": "SuperSecret1", "customerno": "CS602934" } }' \
    http://127.0.0.1:8200/v1/usercreds/data/jjhome7823@example.com

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data '{"data": { "username": "clint.mason312@example.com", "password": "SuperSecret1", "customerno": "CS157843" } }' \
    http://127.0.0.1:8200/v1/usercreds/data/clint.mason312@example.com

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data '{"data": { "username": "greystone89@example.com", "password": "SuperSecret1", "customerno": "CS523484" } }' \
    http://127.0.0.1:8200/v1/usercreds/data/greystone89@example.com

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data '{"data": { "username": "runwayyourway@example.com", "password": "SuperSecret1", "customerno": "CS658871" } }' \
    http://127.0.0.1:8200/v1/usercreds/data/runwayyourway@example.com

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data '{"data": { "username": "olsendog1979@example.com", "password": "SuperSecret1", "customerno": "CS103393" } }' \
    http://127.0.0.1:8200/v1/usercreds/data/olsendog1979@example.com

# Additional configs
curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data "{\"data\": { \"aws_access_key\": \"$AWS_ACCESS_KEY\", \"aws_secret_key\": \"$AWS_SECRET_KEY\", \"aws_region\": \"$REGION\" } }" \
    http://127.0.0.1:8200/v1/secret/data/aws

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data "{\"data\": { \"token\": \"$VAULT_TOKEN\" } }" \
    http://127.0.0.1:8200/v1/secret/data/roottoken

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data "{\"data\": { \"address\": \"customer-db.service.$REGION.consul\", \"database\": \"$MYSQL_DB\", \"username\": \"$MYSQL_USER\", \"password\": \"$MYSQL_PASS\" } }" \
    http://127.0.0.1:8200/v1/secret/data/dbhost

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request PUT \
    --data @/etc/vault.d/nomad-policy.json \
    http://127.0.0.1:8200/v1/sys/policy/nomad-server

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request PUT \
    --data @/etc/vault.d/access-creds.json \
    http://127.0.0.1:8200/v1/sys/policy/access-creds

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data @/etc/vault.d/nomad-cluster-role.json \
    http://127.0.0.1:8200/v1/auth/token/roles/nomad-cluster

echo "Register with Consul"
curl \
    http://127.0.0.1:8500/v1/agent/service/register \
    --request PUT \
    --data @- <<PAYLOAD
{
    "ID": "vault-main",
    "Name": "vault-main",
    "Port": 8200
}
PAYLOAD

echo "Vault installation complete."

# Configures the Nomad server

echo "Installing Nomad..."
curl -sfLo "nomad.zip" "${NOMAD_URL}"
sudo unzip nomad.zip -d /usr/local/bin/
rm -rf nomad.zip

sudo bash -c "cat >/etc/docker/config.json" <<EOF
{
	"credsStore": "ecr-login"
}
EOF

sudo bash -c "cat >/etc/nomad.d/vault-token.json" <<EOF
{
    "policies": [
        "nomad-server"
    ],
    "ttl": "72h",
    "renewable": true,
    "no_parent": true
}
EOF

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data @/etc/nomad.d/vault-token.json \
    http://localhost:8200/v1/auth/token/create | jq . > /etc/nomad.d/token.json

export NOMAD_TOKEN="$(cat /etc/nomad.d/token.json | jq -r .auth.client_token | tr -d '\n')"

sudo bash -c "cat >/etc/nomad.d/nomad.hcl" <<EOF
data_dir  = "/opt/nomad"
plugin_dir = "/opt/nomad/plugins"
bind_addr = "0.0.0.0"
datacenter = "${REGION}"
enable_debug = true

ports {
    http = 4646
    rpc  = 4647
    serf = 4648
}

consul {
    address             = "127.0.0.1:8500"
    server_service_name = "nomad-server"
    client_service_name = "nomad-server"
    auto_advertise      = true
    server_auto_join    = true
    client_auto_join    = true
}

vault {
    enabled          = true
    address          = "http://vault-main.service.${REGION}.consul:8200"
    task_token_ttl   = "1h"
    create_from_role = "nomad-cluster"
    token            = "$NOMAD_TOKEN"
}

server {
    enabled          = true
    bootstrap_expect = 1
}

client {
    enabled       = true
    network_speed = 1000
    options {
        "driver.raw_exec.enable"    = "1"
        # "docker.auth.config"        = "/etc/docker/config.json"
        # "docker.auth.helper"        = "ecr-login"
        # "docker.privileged.enabled" = "true"
    }
    servers = ["nomad-server.service.${REGION}.consul:4647"]
}
EOF

# Set Nomad up as a systemd service
echo "Installing systemd service for Nomad..."
sudo bash -c "cat >/etc/systemd/system/nomad.service" <<EOF
[Unit]
Description=Hashicorp Nomad
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root
ExecStart=/usr/local/bin/nomad agent -config=/etc/nomad.d/nomad.hcl
Restart=on-failure # or always, on-abort, etc

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl start nomad
sudo systemctl enable nomad

cd /root
go get -u github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login
mv /root/go/bin/docker-credential-ecr-login /usr/local/bin

curl \
    http://127.0.0.1:8500/v1/agent/service/register \
    --request PUT \
    --data @- <<PAYLOAD
{
    "ID": "nomad-server",
    "Name": "nomad-server",
    "Port": 4647
}
PAYLOAD

echo "Nomad installation complete."


####################
# Build APIs
####################
cd /root
mkdir /root/components

echo "Get Consul node id..."
export CONSUL_NODE_ID=$(curl -s http://127.0.0.1:8500/v1/catalog/node/consul-server | jq -r .Node.ID)

echo "Enable transit engine..."
# enable transit
curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data '{"type":"transit"}' \
    http://vault-main.service.$REGION.consul:8200/v1/sys/mounts/transit

echo "Create account key..."
curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    http://vault-main.service.$REGION.consul:8200/v1/transit/keys/account

echo "Create payment key..."
curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    http://vault-main.service.$REGION.consul:8200/v1/transit/keys/payment

# register the database host with consul
echo "Registering customer-db with consul..."
curl \
    --request PUT \
    --data "{ \"Datacenter\": \"$REGION\", \"Node\": \"$CONSUL_NODE_ID\", \"Address\":\"$MYSQL_HOST\", \"Service\": { \"ID\": \"customer-db\", \"Service\": \"customer-db\", \"Address\": \"$MYSQL_HOST\", \"Port\": 3306 } }" \
    http://127.0.0.1:8500/v1/catalog/register

# "Checks": [{ "ID": "sqlsvc", "Name": "Port Accessibility", "DeregisterCriticalServiceAfter": "10m", "TCP": "customer-db.service.$REGION.consul:3306", "Interval": "10s", "TTL": "15s", "TLSSkipVerify": true }]

# Create mysql database
echo "Creating database..."
python3 /root/javaperks-aws-single-server/scripts/create_db.py customer-db.service.$REGION.consul $MYSQL_USER $MYSQL_PASS $VAULT_TOKEN $REGION

# load product data
echo "Loading product data..."
python3 /root/javaperks-aws-single-server/scripts/product_load.py $TABLE_PRODUCT $REGION


#################################
# upload product-app images
#################################
# echo "Building productapi..."
cd /root/components
git clone https://github.com/kevincloud/javaperks-product-api.git
cd javaperks-product-api
# Upload images to S3
aws s3 cp /root/components/javaperks-product-api/images/ s3://$S3_BUCKET/images/ --recursive --acl public-read

#################################
# create nomad jobs
#################################
echo "Creating Nomad job files..."

mkdir /root/jobs

sudo bash -c "cat >/root/jobs/auth-api-job.nomad" <<EOF
{
    "Job": {
        "ID": "auth-api-job",
        "Name": "auth-api",
        "Type": "service",
        "Datacenters": ["$REGION"],
        "TaskGroups": [{
            "Name": "auth-api-group",
            "Tasks": [{
                "Name": "auth-api",
                "Driver": "exec",
                "Count": 1,
                "Update": {
                    "Stagger": 10000000000,
                    "MaxParallel": 1,
                    "HealthCheck": "checks",
                    "MinHealthyTime": 10000000000,
                    "HealthyDeadline": 300000000000
                },
                "Vault": {
                    "Policies": ["access-creds"]
                },
                "Config": {
                    "command": "local/javaperks-auth-api"
                },
                "Artifacts": [{
                    "GetterSource": "https://jubican-public.s3-us-west-2.amazonaws.com/bin/javaperks-auth-api",
                    "RelativeDest": "local/"
                }],
                "Templates": [{
                    "EmbeddedTmpl": "VAULT_ADDR = \"http://vault-main.service.$REGION.consul:8200\"\nVAULT_TOKEN = \"$VAULT_TOKEN\"\n",
                    "DestPath": "secrets/file.env",
                    "Envvars": true
                }],
                "Resources": {
                    "CPU": 100,
                    "MemoryMB": 32,
                    "Networks": [{
                        "MBits": 1,
                        "ReservedPorts": [
                            {
                                "Label": "http",
                                "Value": 5825
                            }
                        ]
                    }]
                },
                "Services": [{
                    "Name": "auth-api",
                    "PortLabel": "http"
                }]
            }]
        }]
    }
}
EOF

sudo bash -c "cat >/root/jobs/product-api-job.nomad" <<EOF
{
    "Job": {
        "ID": "product-api-job",
        "Name": "product-api",
        "Type": "service",
        "Datacenters": ["$REGION"],
        "TaskGroups": [{
            "Name": "product-api-group",
            "Count": 3,
            "Tasks": [{
                "Name": "product-api",
                "Driver": "docker",
                "Vault": {
                    "Policies": ["access-creds"]
                },
                "Config": {
                    "image": "jubican/javaperks-product-api:1.1.4",
                    "port_map": [{
                        "svc": 80
                    }]
                },
                "Templates": [{
                    "EmbeddedTmpl": "{{with secret \"secret/data/aws\"}}\nAWS_ACCESS_KEY = \"{{.Data.data.aws_access_key}}\"\nAWS_SECRET_KEY = \"{{.Data.data.aws_secret_key}}\"\n{{end}}\nAWS_REGION = \"$REGION\"\nDDB_TABLE_NAME = \"$TABLE_PRODUCT\"\n",
                    "DestPath": "secrets/file.env",
                    "Envvars": true
                }],
                "Resources": {
                    "CPU": 100,
                    "MemoryMB": 80,
                    "Networks": [{
                        "MBits": 1,
                        "DynamicPorts": [
                            {
                                "Label": "svc",
                                "Value": 0
                            }
                        ]
                    }]
                },
                "Services": [{
                    "Name": "product-api",
                    "PortLabel": "svc"
                }]
            }],
            "Update": {
                "MaxParallel": 3,
                "MinHealthyTime": 10000000000,
                "HealthyDeadline": 180000000000,
                "AutoRevert": false,
                "AutoPromote": false,
                "Canary": 1
            }
        }]
    }
}
EOF

sudo bash -c "cat >/root/jobs/customer-api-job.nomad" <<EOF
{
    "Job": {
        "ID": "customer-api-job",
        "Name": "customer-api",
        "Type": "service",
        "Datacenters": ["$REGION"],
        "TaskGroups": [{
            "Name": "customer-api-group",
            "Tasks": [{
                "Name": "customer-api",
                "Driver": "java",
                "Count": 1,
                "Update": {
                    "Stagger": 10000000000,
                    "MaxParallel": 1,
                    "HealthCheck": "checks",
                    "MinHealthyTime": 10000000000,
                    "HealthyDeadline": 300000000000
                },
                "Vault": {
                    "Policies": ["access-creds"]
                },
                "Config": {
                    "jar_path": "local/javaperks-customer-api-0.2.6.jar",
                    "args": [ "server", "local/config.yml" ]
                },
                "Artifacts": [{
                    "GetterSource": "https://jubican-public.s3-us-west-2.amazonaws.com/jars/javaperks-customer-api-0.2.6.jar",
                    "RelativeDest": "local/"
                }],
                "Templates": [{
                    "EmbeddedTmpl": "logging:\n  level: INFO\n  loggers:\n    com.javaperks.api: DEBUG\nserver:\n  applicationConnectors:\n  - type: http\n    port: 5822\n  adminConnectors:\n  - type: http\n    port: 9001\nvaultAddress: \"http://vault-main.service.$REGION.consul:8200\"\nvaultToken: \"$VAULT_TOKEN\"\n",
                    "DestPath": "local/config.yml"
                }],
                "Resources": {
                    "CPU": 100,
                    "MemoryMB": 256,
                    "Networks": [{
                        "MBits": 1,
                        "ReservedPorts": [
                            {
                                "Label": "http",
                                "Value": 5822
                            }
                        ]
                    }]
                },
                "Services": [{
                    "Name": "customer-api",
                    "PortLabel": "http"
                }]
            }]
        }]
    }
}
EOF

sudo bash -c "cat >/root/jobs/cart-api-job.nomad" <<EOF
{
    "Job": {
        "ID": "cart-api-job",
        "Name": "cart-api",
        "Type": "service",
        "Datacenters": ["$REGION"],
        "TaskGroups": [{
            "Name": "cart-api-group",
            "Count": 1,
            "Tasks": [{
                "Name": "cart-api",
                "Driver": "docker",
                "Vault": {
                    "Policies": ["access-creds"]
                },
                "Config": {
                    "image": "jubican/javaperks-cart-api:1.1.0",
                    "port_map": [{
                        "http": 80
                    }]
                },
                "Templates": [{
                    "EmbeddedTmpl": "{{with secret \"secret/data/aws\"}}\nAWS_ACCESS_KEY_ID = \"{{.Data.data.aws_access_key}}\"\nAWS_SECRET_ACCESS_KEY = \"{{.Data.data.aws_secret_key}}\"\n{{end}}\nREGION = \"$REGION\"\nDDB_TABLE_NAME = \"$TABLE_CART\"\n",
                    "DestPath": "secrets/file.env",
                    "Envvars": true
                }],
                "Resources": {
                    "CPU": 100,
                    "MemoryMB": 64,
                    "Networks": [{
                        "MBits": 1,
                        "DynamicPorts": [
                            {
                                "Label": "http",
                                "Value": 0
                            }
                        ]
                    }]
                },
                "Services": [{
                    "Name": "cart-api",
                    "PortLabel": "http",
                    "Checks": [{
                        "Name": "HTTP Check",
                        "Type": "http",
                        "PortLabel": "http",
                        "Path": "/_health_check",
                        "Interval": 5000000000,
                        "Timeout": 2000000000
                    }]
                }]
            }]
        }]
    }
}
EOF

sudo bash -c "cat >/root/jobs/order-api-job.nomad" <<EOF
{
    "Job": {
        "ID": "order-api-job",
        "Name": "order-api",
        "Type": "service",
        "Datacenters": ["$REGION"],
        "TaskGroups": [{
            "Name": "order-api-group",
            "Count": 3,
            "Tasks": [{
                "Name": "order-api",
                "Driver": "docker",
                "Vault": {
                    "Policies": ["access-creds"]
                },
                "Config": {
                    "image": "jubican/javaperks-order-api:1.1.4",
                    "port_map": [{
                        "http": 80
                    }]
                },
                "Templates": [{
                    "EmbeddedTmpl": "{{with secret \"secret/data/aws\"}}\nAWS_ACCESS_KEY = \"{{.Data.data.aws_access_key}}\"\nAWS_SECRET_KEY = \"{{.Data.data.aws_secret_key}}\"\n{{end}}\nAWS_REGION = \"$REGION\"\nDDB_TABLE_NAME = \"$TABLE_ORDER\"\n",
                    "DestPath": "secrets/file.env",
                    "Envvars": true
                }],
                "Resources": {
                    "CPU": 100,
                    "MemoryMB": 80,
                    "Networks": [{
                        "MBits": 1,
                        "DynamicPorts": [
                            {
                                "Label": "http",
                                "Value": 0
                            }
                        ]
                    }]
                },
                "Services": [{
                    "Name": "order-api",
                    "PortLabel": "http",
                    "Checks": [{
                        "Name": "DB Check",
                        "Type": "http",
                        "PortLabel": "http",
                        "Path": "/_check_ddb",
                        "Interval": 5000000000,
                        "Timeout": 2000000000
                    }, {
                        "Name": "HTTP Check",
                        "Type": "http",
                        "PortLabel": "http",
                        "Path": "/_check_app",
                        "Interval": 5000000000,
                        "Timeout": 2000000000
                    }]
                }]
            }],
            "Update": {
                "MaxParallel": 1,
                "MinHealthyTime": 10000000000,
                "HealthyDeadline": 180000000000,
                "AutoRevert": true,
                "AutoPromote": true,
                "Canary": 3
            }
        }]
    }
}
EOF

sudo bash -c "cat >/root/jobs/online-store-job.nomad" <<EOF
{
    "Job": {
        "ID": "online-store-job",
        "Name": "online-store",
        "Type": "service",
        "Datacenters": ["$REGION"],
        "TaskGroups": [{
            "Name": "online-store-group",
            "Tasks": [{
                "Name": "online-store",
                "Driver": "docker",
                "Vault": {
                    "Policies": ["access-creds"]
                },
                "Config": {
                    "image": "jubican/javaperks-online-store:latest",
                    "dns_servers": ["169.254.1.1"],
                    "port_map": [{
                        "http": 80
                    }]
                },
                "Templates": [{
                    "EmbeddedTmpl": "{{with secret \"secret/data/aws\"}}\nAWS_ACCESS_KEY = \"{{.Data.data.aws_access_key}}\"\nAWS_SECRET_KEY = \"{{.Data.data.aws_secret_key}}\"\n{{end}}{{with secret \"secret/data/roottoken\"}}\nVAULT_TOKEN = \"{{.Data.data.token}}\"\n{{end}}\nREGION = \"$REGION\"\nS3_BUCKET = \"$S3_BUCKET\"\n                ",
                    "DestPath": "secrets/file.env",
                    "Envvars": true
                }],
                "Resources": {
                    "CPU": 100,
                    "MemoryMB": 64,
                    "Networks": [{
                        "MBits": 1,
                        "ReservedPorts": [
                           {
                                "Label": "http",
                                "Value": 80
                            }
                        ]
                    }]
                },
                "Services": [{
                    "Name": "online-store",
                    "PortLabel": "http"
                }]
            }]
        }]
    }
}
EOF

echo "Submitting Nomad jobs..."
curl \
    --request POST \
    --data @/root/jobs/auth-api-job.nomad \
    http://nomad-server.service.$REGION.consul:4646/v1/jobs

curl \
    --request POST \
    --data @/root/jobs/product-api-job.nomad \
    http://nomad-server.service.$REGION.consul:4646/v1/jobs

curl \
    --request POST \
    --data @/root/jobs/cart-api-job.nomad \
    http://nomad-server.service.$REGION.consul:4646/v1/jobs

curl \
    --request POST \
    --data @/root/jobs/order-api-job.nomad \
    http://nomad-server.service.$REGION.consul:4646/v1/jobs

curl \
    --request POST \
    --data @/root/jobs/online-store-job.nomad \
    http://nomad-server.service.$REGION.consul:4646/v1/jobs

curl \
    --request POST \
    --data @/root/jobs/customer-api-job.nomad \
    http://nomad-server.service.$REGION.consul:4646/v1/jobs

echo "Creating Consul intentions..."

curl \
    --request POST \
    --data "{ \"SourceName\": \"customer-api\", \"DestinationName\": \"customer-db\", \"SourceType\": \"consul\", \"Action\": \"allow\" }" \
    http://127.0.0.1:8500/v1/connect/intentions

curl \
    --request POST \
    --data "{ \"SourceName\": \"online-store\", \"DestinationName\": \"customer-api\", \"SourceType\": \"consul\", \"Action\": \"allow\" }" \
    http://127.0.0.1:8500/v1/connect/intentions

curl \
    --request POST \
    --data "{ \"SourceName\": \"*\", \"DestinationName\": \"customer-db\", \"SourceType\": \"consul\", \"Action\": \"deny\" }" \
    http://127.0.0.1:8500/v1/connect/intentions

curl \
    --request POST \
    --data "{ \"SourceName\": \"*\", \"DestinationName\": \"customer-api\", \"SourceType\": \"consul\", \"Action\": \"deny\" }" \
    http://127.0.0.1:8500/v1/connect/intentions

# now that the services are running, need to reload nginx config
service consul-template stop
service consul-template start
service nginx reload

# all done!
echo "Javaperks Application complete."
