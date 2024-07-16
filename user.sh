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
   VALIDATE $? "Creating the roboshop user"
else
   echo -e "Roboshop user already exists ---$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOG_FILE
VALIDATE $? "Download user zip file"

cd /app
unzip -o /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "Unzip the user zip file"

cd /app
npm install &>>$LOG_FILE    
VALIDATE $? "Installing NPM" 

cp /home/centos/reddy-roboshop-sell/user.service /etc/systemd/system/user.service &>>$LOG_FILE
VALIDATE $? "Copying user.service file"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reload daemon"

systemctl enable user &>>$LOG_FILE
VALIDATE $? "Enable user"

systemctl start user &>>$LOG_FILE
VALIDATE $? "Starting the user"

cp /home/centos/reddy-roboshop-sell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "Copying the mongo.repo"

dnf install mongodb-org-shell -y &>>$LOG_FILE
VALIDATE $? "install mongodb-org-sell client install"

mongo --host 172.31.23.31 </app/schema/user.js  &>>$LOG_FILE
VALIDATE $? "Loading user data into mongoDB"  