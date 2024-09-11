#!/bin/bash

IMAGE_ID=ami-0182f373e66f89c85
SG_ID=sg-06b8a8118fee179ad
INSTANCES=( "mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web" )

for i in "${INSTANCES[@]}"
do
echo "instances is: $i"
if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
then
     INSTANCE_TYPE="t3.small"
else
     INSTANCE_TYPE="t2.micro"
fi
aws ec2 run-instances --image-id $IMAGE_ID  --instance-type $INSTANCE_TYPE   --security-group-ids $SG_ID 

done