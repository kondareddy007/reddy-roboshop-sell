#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
TIME_STAMP=$(date +%F:%H:%M:%S)
LOG_FILE=/tmp/$0_$TIME_STAMP.log

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 ...$R Failed $N"
        exit 1
    else
        echo -e "$2 ....$G Success $N"
  fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R Error:: Please run this script with root access"
    exit 1
else
    echo "$G you are root user"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>LOG_FILE
VALIDATE $? "Cpoied mongo.repo"

dnf install mongodb-org -y  &>>LOG_FILE
VALIDATE $? "Installing MongoDB"

systemctl enable mongod   &>>LOG_FILE
VALIDATE $? "Enable  MongoDB Service"

systemctl start mongod &>>LOG_FILE
VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0./g' /etc/mongod.conf &>>LOG_FILE
VALIDATE $? "Remote access to mondoDB"

systemctl restart mongod &>>LOG_FILE
VALIDATE $? "Restart the mongoDB"

