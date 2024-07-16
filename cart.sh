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
VALIDATE $? "Disabled old notejs"

dnf module enable nodejs:18 -y &>>$LOG_FILE
VALIDATE $? "Enabled nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs"

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

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>>$LOG_FILE
VALIDATE $? "Download cart zip file"

cd /app
unzip -o /tmp/cart.zip &>>$LOG_FILE
VALIDATE $? "Unzip the cart zip file"

cd /app
npm install &>>$LOG_FILE    
VALIDATE $? "Installing NPM" 

cp /home/centos/reddy-roboshop-sell/cart.service /etc/systemd/system/cart.service &>>$LOG_FILE
VALIDATE $? "Copying cart.service file"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reload daemon"

systemctl enable cart &>>$LOG_FILE
VALIDATE $? "Enable cart"

systemctl start cart &>>$LOG_FILE
VALIDATE $? "Starting the cart"

  