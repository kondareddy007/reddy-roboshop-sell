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
    echo -e "$G You are root user $N"
fi

dnf install python36 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Install python"

id roboshop
if [ $? -ne 0 ]
then
   useradd roboshop
   VALIDATE $? "creating the roboshop user"
else
   echo -e "roboshop user already exists ---$Y SKIPPING $N"
fi

mkdir -p /app  &>>$LOG_FILE
VALIDATE $? "Created app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOG_FILE
VALIDATE $? "Downloading payment zip file"

cd /app 

unzip -o /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "Unzip payment zip file"

cd /app 

pip3.6 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Install requiremnets"

cp /home/centos/reddy-roboshop-sell/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATE $? "Copying payment.services into /etc/systemd/system/ folder"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reload daemon"

systemctl enable payment  &>>$LOG_FILE
VALIDATE $? "Enable payment"

systemctl start payment &>>$LOG_FILE
VALIDATE $? "Started payment"



