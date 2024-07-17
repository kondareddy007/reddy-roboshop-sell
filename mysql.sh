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

dnf module disable mysql -y $LOG_FILE
VALIDATE $? "Disable mysql "

cp /home/centos/reddy-roboshop-sell/mysql.repo /etc/yum.repos.d/mysql.repo $LOG_FILE
VALIDATE $? "Copying the mysql.repo data"

dnf install mysql-community-server -y $LOG_FILE
VALIDATE $? "Installing  mysql server"

systemctl enable mysqld $LOG_FILE
VALIDATE $? "Enable mysql "


systemctl start mysqld  $LOG_FILE
VALIDATE $? "Starting mysql "

mysql_secure_installation --set-root-pass RoboShop@1 $LOG_FILE
VALIDATE $? "Creating the  mysql password "

mysql -uroot -pRoboShop@1 $LOG_FILE
VALIDATE $? "Checking  mysql password working or not"


