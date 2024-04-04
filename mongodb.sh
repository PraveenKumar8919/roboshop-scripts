#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[30m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGGFILE=/tmp/$0-$TIMESTAMP.log

echo "Scrip executed on time:: $TIMESTAMP" &>> $LOGGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .. $R FAILED $N"
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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> LOGGFILE

VALIDATE $? "Copied mongodb repo"

dnf install mongodb-org -y &>> $LOGGFILE

VALIDATE $? "installation of mongodb"

systemctl enable mongod &>> $LOGGFILE

VALIDATE $? "Enabling mongodb"

systemctl start mongod &>> $LOGGFILE

VALIDATE $? "Starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGGFILE

VALIDATE $? "Remote IP updating"

systemctl restart mongod &>> $LOGGFILE

VALIDATE $? "Restarting mongodb"