#!/bin/bash

echo "Creating order api job file..."
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
                "Stagger": 30000000000,
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

echo "Submitting order api job..."
curl \
    --request POST \
    --data @/root/jobs/order-api-job.nomad \
    http://nomad-server.service.$REGION.consul:4646/v1/jobs

# Wait for order api services to come online
STATUS=""
SVCCNT=0
echo "Waiting for order-api service to become healthy..."
while [ "$STATUS" != "passing" ]; do
        sleep 2
        STATUS="passing"
        SVCCNT=$(($SVCCNT + 1))
        if [ $SVCCNT -gt 20 ]; then
            echo "...status check timed out"
            break
        fi
        curl -s http://127.0.0.1:8500/v1/health/service/order-api > order-api-status.txt
        outcount=`cat order-api-status.txt  | jq -r '. | length'`
        for ((oc = 0; oc < $outcount ; oc++ )); do
                incount=`cat order-api-status.txt  | jq -r --argjson oc $oc '.[$oc].Checks | length'`
                for ((ic = 0; ic < $incount ; ic++ )); do
                        indstatus=`cat order-api-status.txt  | jq -r --argjson oc $oc --argjson ic $ic '.[$oc].Checks[$ic].Status'`
                        if [ "$indstatus" != "passing" ]; then
                                STATUS=""
                        fi
                done
        done
        rm order-api-status.txt
        if [ "$indstatus" != "passing" ]; then
                echo "...checking again"
        fi
done
echo "Done."
