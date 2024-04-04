#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.praveenaws.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGGFILE=/tmp/$0-$TIMESTAMP.log

echo "Scrip executed on time:: $TIMESTAMP" &>> $LOGGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .. $R FAILED $N"
        exit 1
    else
        echo -e "$2 .. $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e " $R Please try with root user access:: $N"
    exit 1
else
    echo -e "You are a root user ::"
fi

dnf module disable nodejs -y &>> $LOGGFILE
VALIDATE $? "disabling module nodejs"

dnf module enable nodejs:18 -y &>> $LOGGFILE
VALIDATE $? "Enabling nodejs18"

dnf install nodejs -y &>> $LOGGFILE
VALIDATE $? "Installing nodejs"

id=roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop
    $VALIDATE $? "roboshop user creation"
else
    echo "User roboshop already exits $Y Skipping $N"
fi

mkdir -p /app

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGGFILE
VALIDATE $? "Downloading catalogue"

cd /app
VALIDATE $? "Changing to app directory"

unzip -o /tmp/catalogue.zip &>> $LOGGFILE
VALIDATE $? "Unzipping catalogue service:" 

npm install &>> $LOGGFILE
VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-scripts/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying catalogue service"

systemctl daemon-reload &>> $LOGGFILE
VALIDATE $? "Catalogue deamon reload" 

systemctl enable catalogue
VALIDATE $? "Enabling catalogue service"

systemctl start catalogue
VALIDATE $? "Starting Catalogue service"

cp /home/centos/roboshop-scripts/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongo repo"

dnf install mongodb-org-shell -y &>> $LOGGFILE
VALIDATE $? "installing mongo db client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js
VALIDATE $? "loading catalogue data into mongodb"




