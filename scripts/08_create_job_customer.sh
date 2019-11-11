#!/bin/bash

echo "Creating customer api job file..."
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

echo "Submitting customer api job..."
curl \
    --request POST \
    --data @/root/jobs/customer-api-job.nomad \
    http://nomad-server.service.$REGION.consul:4646/v1/jobs

# Wait for customer api services to come online
STATUS=""
SVCCNT=0
echo "Waiting for customer-api service to become healthy..."
while [ "$STATUS" != "passing" ]; do
        sleep 2
        STATUS="passing"
        SVCCNT=$(($SVCCNT + 1))
        if [ $SVCCNT -gt 20 ]; then
            echo "...status check timed out"
            break
        fi
        curl -s http://127.0.0.1:8500/v1/health/service/customer-api > customer-api-status.txt
        outcount=`cat customer-api-status.txt  | jq -r '. | length'`
        for ((oc = 0; oc < $outcount ; oc++ )); do
                incount=`cat customer-api-status.txt  | jq -r --argjson oc $oc '.[$oc].Checks | length'`
                for ((ic = 0; ic < $incount ; ic++ )); do
                        indstatus=`cat customer-api-status.txt  | jq -r --argjson oc $oc --argjson ic $ic '.[$oc].Checks[$ic].Status'`
                        if [ "$indstatus" != "passing" ]; then
                                STATUS=""
                        fi
                done
        done
        rm customer-api-status.txt
        if [ "$indstatus" != "passing" ]; then
                echo "...checking again"
        fi
done
echo "Done."

# echo "Creating Consul intentions..."

# curl \
#     --request POST \
#     --data "{ \"SourceName\": \"customer-api\", \"DestinationName\": \"customer-db\", \"SourceType\": \"consul\", \"Action\": \"allow\" }" \
#     http://127.0.0.1:8500/v1/connect/intentions

# curl \
#     --request POST \
#     --data "{ \"SourceName\": \"online-store\", \"DestinationName\": \"customer-api\", \"SourceType\": \"consul\", \"Action\": \"allow\" }" \
#     http://127.0.0.1:8500/v1/connect/intentions

# curl \
#     --request POST \
#     --data "{ \"SourceName\": \"*\", \"DestinationName\": \"customer-db\", \"SourceType\": \"consul\", \"Action\": \"deny\" }" \
#     http://127.0.0.1:8500/v1/connect/intentions

# curl \
#     --request POST \
#     --data "{ \"SourceName\": \"*\", \"DestinationName\": \"customer-api\", \"SourceType\": \"consul\", \"Action\": \"deny\" }" \
#     http://127.0.0.1:8500/v1/connect/intentions

