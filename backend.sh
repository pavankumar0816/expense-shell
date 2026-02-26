#!/bin/bash

source ./common.sh
app_name=backend

check_root

if command -v node &>/dev/null && node -v | grep -q "^v20"; then
      echo "Nodejs 20 is already installed $Y Skipping ... $N" | tee -a $LOGS_FILE
   else
      dnf module disable nodejs -y
      validate $? "Disbaling Nodejs 20 version"

      dnf module enable nodejs:20 -y &>>$LOGS_FILE
      validate $? "Enabling Nodejs 20 version"

      dnf install nodejs -y &>>$LOGS_FILE
      validate $? "Installing Nodejs"
fi

app_setup

npm install &>>$LOGS_FILE
validate $? "Installing dependencies"

systemd_setup
mysql_client
app_restart

print_total_time