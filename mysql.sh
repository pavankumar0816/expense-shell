#!/bin/bash

source ./common.sh
check_root
 
dnf install mysql-server -y &>>$LOGS_FILE
validate $? "Isntallation "

systemctl enable mysqld &>>$LOGS_FILE
systemctl start mysqld
validate $? "Enable and start mysql"

mysql_secure_installation --set-root-pass $MYSQL_PASSWORD &>>$LOGS_FILE
validate $? "Setting mysql root password"

mysql -h <host-address> -u root -p$MYSQL_PASSWORD &>>$LOGS_FILE
validate $? "connect to mysql server"

mysql
show databases;
show tables;

print_total_time