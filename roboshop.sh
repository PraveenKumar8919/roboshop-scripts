#!/bin/bash

AMI=ami-0f3c7d07486cad139
SG_ID=sg-0c8148ec0e96e151f
ZONE_ID=Z1008359UKTGUBJTPVRW
DOMAIN_NAME=praveenaws.online

INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")

for i in "${INSTANCES[@]}"
do
    echo "Instance type is :: $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    IP_ADDRESS=$(aws ec2 run-instances --image-id ami-0f3c7d07486cad139 --instance-type $INSTANCE_TYPE --security-group-ids sg-0c8148ec0e96e151f --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query "Instances[0].PrivateIpAddress" --output text)
    echo "$i : $IP_ADDRESS"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT" 
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }
        '
done

#changing CREATE in Action column to UPSERT.. This means if     r53  records exists it will update with new ip, if not exists it will create





