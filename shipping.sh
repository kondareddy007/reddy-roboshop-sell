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

dnf install maven -y  $LOG_FILE
VALIDATE $? "Install maven"


id roboshop
if [ $? -ne 0 ]
then
   useradd roboshop
   VALIDATE $? "Creating the roboshop user"
else
   echo -e "Roboshop user already exists ---$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Create app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$LOG_FILE
VALIDATE $? "Downloading shipping  zip file"

cd /app

unzip -o /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "Unzip the shipping zip file"

cd /app

mvn clean package &>>$LOG_FILE
VALIDATE $? "maven commands"

mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATE $? "Moving shipping jar file into target folder"

cp /home/centos/reddy-roboshop-sell/shipping.service /etc/systemd/system/shipping.service  &>>$LOG_FILE
VALIDATE $? "Copying shipping services into /etc/systemd/system/ folder"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reload the daemon"

systemctl enable shipping  &>>$LOG_FILE
VALIDATE $? "Enable shipping"

systemctl start shipping &>>$LOG_FILE
VALIDATE $? "Started shipping"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installed mysql"

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restart shipping"


