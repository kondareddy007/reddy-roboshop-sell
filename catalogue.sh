#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
TIME_STAMP=$(date +%F:%H:%M:%S)
LOG_FILE=/tmp/$0_$TIME_STAMP.log

MONGODB_HOST=172.31.29.138

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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disabled old notejs"

dnf module enable nodejs:18 -y &>>$LOG_FILE
VALIDATE $? "enabled nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "installing nodejs"

id roboshop
if [ $? -ne 0 ]
then
   useradd roboshop
   VALIDATE $? "creating the roboshop user"
else
   echo -e "roboshop user already exists ---$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOG_FILE
VALIDATE $? "download catlogue zip file"

cd /app
unzip -o /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzip the catalogue zip file"

cd /app
npm install &>>$LOG_FILE
VALIDATE $? "installing NPM" 

cp /home/centos/reddy-roboshop-sell/catalogue.service /etc/systemd/system/catalogue.service &>>$LOG_FILE
VALIDATE $? "copying catalogue.service file"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reload daemon"

systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "enable catalogue"

systemctl start catalogue &>>$LOG_FILE
VALIDATE $? "strating the catalogue"

cp /home/centos/reddy-roboshop-sell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "copying the mongo.repo"

dnf install mongodb-org-shell -y &>>$LOG_FILE
VALIDATE $? "install mongodb-org-sell client install"

mongo --host MONGODB_HOST </app/schema/catalogue.js  &>>$LOG_FILE
VALIDATE $? "Loading calogue into mongoDB"