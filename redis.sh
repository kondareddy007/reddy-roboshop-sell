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
    echo -e "$G you are root user $N"
fi

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$LOG_FILE
VALIDATE $? "Installing dnf"

dnf module enable redis:remi-6.2 -y &>>$LOG_FILE
VALIDATE $? "Enabling dnf module"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing Redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf &>>$LOG_FILE
VALIDATE $? "Chnage the valu from 127.0.0.1 to 0.0.0.0 in /etc/redis.conf"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "Chnage the valu from 127.0.0.1 to 0.0.0.0 in /etc/redis/redis.conf"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "Starting the redis"


