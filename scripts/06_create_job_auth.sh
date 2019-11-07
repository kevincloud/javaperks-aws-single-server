#!/bin/bash

echo "Creating auth api job file..."
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
                    "command": "local/javaperks-auth-api-1.1.5"
                },
                "Artifacts": [{
                    "GetterSource": "https://jubican-public.s3-us-west-2.amazonaws.com/bin/javaperks-auth-api-1.1.5",
                    "RelativeDest": "local/"
                }],
                "Templates": [{
                    "EmbeddedTmpl": "VAULT_ADDR = \"http://vault-main.service.$REGION.consul:8200\"\nVAULT_TOKEN = \"$VAULT_TOKEN\"\nLDAP_HOST = \"$CLIENT_IP\"\nLDAP_ADMIN = \"$LDAP_ADMIN_USER\"\nLDAP_PASSWORD = \"$LDAP_ADMIN_PASS\"\n",
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

echo "Submitting auth api job..."
curl \
    --request POST \
    --data @/root/jobs/auth-api-job.nomad \
    http://nomad-server.service.$REGION.consul:4646/v1/jobs

# Wait for auth api services to come online
STATUS=""
SVCCNT=0
echo "Waiting for auth-api service to become healthy..."
while [ "$STATUS" != "passing" ]; do
        sleep 2
        STATUS="passing"
        SVCCNT=$(($SVCCNT + 1))
        if [ $SVCCNT -gt 20 ]; then
            echo "...status check timed out"
            break
        fi
        curl -s http://127.0.0.1:8500/v1/health/service/auth-api > auth-api-status.txt
        outcount=`cat auth-api-status.txt  | jq -r '. | length'`
        for ((oc = 0; oc < $outcount ; oc++ )); do
                incount=`cat auth-api-status.txt  | jq -r --argjson oc $oc '.[$oc].Checks | length'`
                for ((ic = 0; ic < $incount ; ic++ )); do
                        indstatus=`cat auth-api-status.txt  | jq -r --argjson oc $oc --argjson ic $ic '.[$oc].Checks[$ic].Status'`
                        if [ "$indstatus" != "passing" ]; then
                                STATUS=""
                        fi
                done
        done
        rm auth-api-status.txt
        if [ "$indstatus" != "passing" ]; then
                echo "...checking again"
        fi
done
echo "Done."

