#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGGFILE="/tmp/$0-$TIMESTAMP.log"
echo "script executed on $TIMESTAMP" &>>LOGGFILE

VALIDATE()
{
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 ... $R Failed $N"
        exit 1
    else
        echo -e "$2 .... $G Success $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R Please run the script as a root user $N"
    exit 1
else
    echo -e "$G You are a root user $N"
fi

dnf module disable nodejs -y &>> $LOGGFILE
VALIDATE $? "Disabling current NodeJS"

dnf module enable nodejs:18 -y  &>> $LOGGFILE
VALIDATE $? "Enabling NodeJS:18"

dnf install nodejs -y  &>> $LOGGFILE
VALIDATE $? "Installing NodeJS:18"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo "ROboshop user already exits"
fi

mkdir -p /app
VALIDATE $? "creating app directory"

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip  &>> $LOGGFILE
VALIDATE $? "Downloading cart application"

cd /app 

unzip -o /tmp/cart.zip  &>> $LOGGFILE
VALIDATE $? "unzipping cart"

npm install  &>> $LOGGFILE
VALIDATE $? "Installing dependencies"

# use absolute, because cart.service exists there
cp /home/centos/roboshop-scripts/cart.service /etc/systemd/system/cart.service &>> $LOGGFILE
VALIDATE $? "Copying cart service file"

systemctl daemon-reload &>> $LOGGFILE
VALIDATE $? "cart daemon reload"

systemctl enable cart &>> $LOGGFILE
VALIDATE $? "Enable cart"

systemctl start cart &>> $LOGGFILE
VALIDATE $? "Starting cart"