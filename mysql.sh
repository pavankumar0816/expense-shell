#!/bin/bash

source ./common.sh
check_root
 
dnf install mysql-server -y &>>$LOGS_FILE
validate $? "Isntallation "

systemctl enable mysqld &>>$LOGS_FILE
systemctl start mysqld
validate $? "Enable and start mysql"

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGS_FILE
validate $? "Setting mysql root password"

mysql -h mysql.pmpkdev.online -u root -pExpenseApp@1 &>>$LOGS_FILE
validate $? "connect to mysql server"

print_total_time