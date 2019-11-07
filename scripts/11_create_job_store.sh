#!/bin/bash

echo "Creating online store job file..."
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


echo "Submitting online store job..."
curl \
    --request POST \
    --data @/root/jobs/online-store-job.nomad \
    http://nomad-server.service.$REGION.consul:4646/v1/jobs

# Wait for online store to come online
STATUS=""
SVCCNT=0
echo "Waiting for online-store service to become healthy..."
while [ "$STATUS" != "passing" ]; do
        sleep 2
        STATUS="passing"
        SVCCNT=$(($SVCCNT + 1))
        if [ $SVCCNT -gt 20 ]; then
            echo "...status check timed out for online-store"
            break
        fi
        curl -s http://127.0.0.1:8500/v1/health/service/online-store > online-store-status.txt
        outcount=`cat online-store-status.txt  | jq -r '. | length'`
        for ((oc = 0; oc < $outcount ; oc++ )); do
                incount=`cat online-store-status.txt  | jq -r --argjson oc $oc '.[$oc].Checks | length'`
                for ((ic = 0; ic < $incount ; ic++ )); do
                        indstatus=`cat online-store-status.txt  | jq -r --argjson oc $oc --argjson ic $ic '.[$oc].Checks[$ic].Status'`
                        if [ "$indstatus" != "passing" ]; then
                                STATUS=""
                        fi
                done
        done
        rm online-store-status.txt
        if [ "$indstatus" != "passing" ]; then
                echo "...checking online-store again"
        fi
done
echo "Done."
