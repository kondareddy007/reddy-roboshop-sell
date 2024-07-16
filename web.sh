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

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing the NGINX server"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enabling the nginx server"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Starting the nginx server"

http://34.229.197.124:80 &>>$LOG_FILE
VALIDATE $? "Access to the nginx server"

rm -rf /usr/share/nginx/html/*  &>>$LOG_FILE
VALIDATE $? "Removing the html files in nginx"


curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip  &>>$LOG_FILE
VALIDATE $? "Downloding the web zip file"

cd /usr/share/nginx/html &>>$LOG_FILE
VALIDATE $? "Moving to html folder in nginx server"

unzip -o /tmp/web.zip &>>$LOG_FILE
VALIDATE $? "Unzip the web zip file"

cp /home/centos/reddy-roboshop-sell/roboshop.conf /etc/nginx/default.d/roboshop.conf  &>>LOG_FILE
VALIDATE $? "Copy roboshop reverse proxy config"

systemctl restart nginx  &>>$LOG_FILE
VALIDATE $? "Restart the NGINX Server"

