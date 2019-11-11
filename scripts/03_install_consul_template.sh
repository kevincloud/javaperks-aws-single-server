#!/bin/bash

# Configure the load balancer for "product-api"
sudo bash -c "cat >>/etc/nginx/conf.d/lb-product-api.conf.ctmpl" <<EOF
upstream product-api-lb {
{{ range service "product-api" }}
    server {{ .Address }}:{{ .Port }};
{{ end }}
}

server {
   listen 5821;

   location / {
      proxy_pass                  http://product-api-lb;
   }
}
EOF

# Configure the load balancer for "cart-api"
sudo bash -c "cat >>/etc/nginx/conf.d/lb-cart-api.conf.ctmpl" <<EOF
upstream cart-api-lb {
{{ range service "cart-api" }}
    server {{ .Address }}:{{ .Port }};
{{ end }}
}

server {
   listen 5823;

   location / {
      proxy_pass                  http://cart-api-lb;
   }
}
EOF

# Configure the load balancer for "order-api"
sudo bash -c "cat >>/etc/nginx/conf.d/lb-order-api.conf.ctmpl" <<EOF
upstream order-api-lb {
{{ range service "order-api" }}
    server {{ .Address }}:{{ .Port }};
{{ end }}
}

server {
   listen 5826;

   location / {
      proxy_pass                  http://order-api-lb;
   }
}
EOF

# remove default website files from nginx
rm -rf /etc/nginx/sites-enabled/*
service nginx reload

# Install Consul Template

echo "Installing Consul Template..."

curl -sfLo "consul-template.zip" "${CTEMPLATE_URL}"
sudo unzip consul-template.zip -d /usr/local/bin/
rm -rf consul-template.zip

sudo bash -c "cat >>/etc/consul.d/template/consul-template-config.hcl" <<EOF
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

reload_signal = "SIGHUP"
kill_signal = "SIGINT"
log_level = "debug"

syslog {
  enabled = true
  facility = "LOCAL5"
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
echo "Installing systemd service for Consul Template..."
sudo bash -c "cat >/etc/systemd/system/consul-template.service" <<EOF
[Unit]
Description=Hashicorp Consul Template
Requires=network-online.target
After=network-online.target

[Service]
User=root
Group=root
ExecStart=/usr/local/bin/consul-template -config=/etc/consul.d/template/consul-template-config.hcl -pid-file=/var/run/consul/consul-template.pid
SuccessExitStatus=12
ExecReload=/bin/kill -SIGHUP \$MAINPID
ExecStop=/bin/kill -SIGINT \$MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=always
RestartSec=42s
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

chown -R consul:consul /etc/nginx/conf.d

echo "Enable Consul Template service..."
sudo systemctl enable consul-template

echo "Consul Template installation complete."

