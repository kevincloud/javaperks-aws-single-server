#!/bin/bash

echo "Creating openldap job file..."
sudo bash -c "cat >/root/jobs/openldap-job.nomad" <<EOF
{
    "Job": {
        "ID": "openldap-job",
        "Name": "openldap",
        "Type": "service",
        "Datacenters": ["$REGION"],
        "TaskGroups": [{
            "Name": "openldap-group",
            "Count": 1,
            "Tasks": [{
                "Name": "openldap",
                "Driver": "docker",
                "Vault": {
                    "Policies": ["access-creds"]
                },
                "Config": {
                    "image": "osixia/openldap:1.3.0",
                    "port_map": [{
                        "svc": 389
                    }]
                },
                "Env": {
                    "LDAP_HOSTNAME": "ldap.javaperks.local",
                    "LDAP_DOMAIN": "javaperks.local",
                    "LDAP_ADMIN_PASSWORD": "$LDAP_ADMIN_PASS",
                    "LDAP_CONFIG_PASSWORD": "$LDAP_ADMIN_PASS"
                },
                "Resources": {
                    "CPU": 100,
                    "MemoryMB": 80,
                    "Networks": [{
                        "MBits": 1,
                        "ReservedPorts": [
                            {
                                "Label": "svc",
                                "Value": 389
                            }
                        ]
                    }]
                },
                "Services": [{
                    "Name": "openldap",
                    "PortLabel": "svc"
                }]
            }]
        }]
    }
}
EOF

# Submit openldap job
curl \
    --request POST \
    --data @/root/jobs/openldap-job.nomad \
    http://nomad-server.service.$REGION.consul:4646/v1/jobs

# Wait for openldap to come online
STATUS=""
SVCCNT=0
echo "Waiting for openldap service to become healthy..."
while [ "$STATUS" != "passing" ]; do
        sleep 2
        STATUS="passing"
        SVCCNT=$(($SVCCNT + 1))
        if [ $SVCCNT -gt 20 ]; then
            echo "...status check timed out for openldap"
            break
        fi
        curl -s http://127.0.0.1:8500/v1/health/service/openldap > openldap-status.txt
        outcount=`cat openldap-status.txt  | jq -r '. | length'`
        for ((oc = 0; oc < $outcount ; oc++ )); do
                incount=`cat openldap-status.txt  | jq -r --argjson oc $oc '.[$oc].Checks | length'`
                for ((ic = 0; ic < $incount ; ic++ )); do
                        indstatus=`cat openldap-status.txt  | jq -r --argjson oc $oc --argjson ic $ic '.[$oc].Checks[$ic].Status'`
                        if [ "$indstatus" != "passing" ]; then
                                STATUS=""
                        fi
                done
        done
        rm openldap-status.txt
        if [ "$indstatus" != "passing" ]; then
                echo "...checking openldap again"
        fi
done

# wait for openldap to become active

sleep 5

STATUS=""
SVCCNT=0
while [ "$STATUS" != "top" ]; do
    SVCCNT=$(($SVCCNT + 1))
    if [ $SVCCNT -gt 20 ]; then
        echo "...status check timed out for openldap"
        break
    fi
    sleep 2
    STATUS=$(curl -s ldap://$CLIENT_IP:389 | sed -n -e '0,/^\tobjectClass/p' | awk -F ": " '{print $2}' | sed '/^$/d')
    if [ "$STATUS" != "top" ]; then
        echo "...checking openldap again"
    fi
done
echo "Done."
