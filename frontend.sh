#!/bin/bash

source ./common.sh
check_root 

if command -v nginx &>/dev/null; then
   echo "Nginx is already installed $Y SKIPPING ... $N" | tee -a $LOGS_FILE
else
    dnf install nginx -y  | tee -a $LOGS_FILE
    validate $? "Installation "
fi

systemctl enable nginx &>>$LOGS_FILE
systemctl start nginx
validate $? "Enabling and starting the NGINX"

rm -rf /usr/share/nginx/html/* &>>$LOGS_FILE
validate $? "Remove the default content"

curl -o /tmp/frontend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGS_FILE
validate $? "Downlading the frontend content"

cd /usr/share/nginx/html
validate $? "Changing to root html directory"

unzip /tmp/frontend.zip &>>$LOGS_FILE
validate $? "Extracting the frontend content"

cp $SCRIPT_DIR/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGS_FILE
validate $? "copying expense config file"

systemctl restart nginx &>>$LOGS_FILE
validate $? "Restarting Nginx"

print_total_time