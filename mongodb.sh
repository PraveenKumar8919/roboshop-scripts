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
        echo -e "$2... $R SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e " $R Please try with root user access:: $N"
    exit 1
else
    echo -e "$G You are a root user :: $N"
fi

cp mongodb.repo /etc/yum.repos.d/mongo.repo &>> LOGGFILE

VALIDATE $? " mongodb"

