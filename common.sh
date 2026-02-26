userid=$(id -u)
LOGS_FOLDER="/var/log/shell-expense"
LOGS_FILE="$LOGS_FOLDER/$0.log"
START_TIME=$(date +%s)
SCRIPT_DIR=$PWD
MYSQL_PASSWORD="ExpenseApp@1"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

mkdir -p $LOGS_FOLDER

echo "$(date "+%Y-%m-%d %H:%M:%S") | Script Execution Started" | tee -a $LOGS_FILE


check_root(){
if [ $userid -ne 0 ]; then
  echo -e "$R Run using sudo access $N "
  exit 1
fi
}

validate(){
    if [ $1 -ne 0 ]; then
       echo -e "$2 is $R Failed $N ..."
       exit 1
    else
       echo -e "$2 is $G Success $N ..."
    fi
}

app_setup(){
    id expense &>>$LOGS_FILE
    if [ $? -ne 0 ]; then
    useradd expense &>>$LOGS_FILE
    validate $? "Creating system user"
    else
    echo -e "$Y Expense user already exists $N"
    fi

    mkdir /app
    validate $? "Cretaing app directory"

    curl -o /tmp/$app_name.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-$app_name-v2.zip &>>$LOGS_FILE
    validate $? "Downloading Expense $app_name content"

    cd /app
    validate $? "Moving to App Directory"

    rm -rf /app/*
    validate $? "Removing Existing Code"

    unzip /tmp/$app_name.zip &>>$LOGS_FILE
    validate $? "Extracting Expense app content"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service &>>$LOGS_FILE
    validate $? "Created the Systemctl service"

    
    systemctl daemon-reload
    systemctl enable $app_name &>>$LOGS_FILE
    systemctl start $app_name
    validate $? "Enable and start $app_name"
}

app_restart(){
    systemctl restart $app_name
    validate $? "restarting the $app_name service"
}

mysql_client(){
    dnf install mysql -y &>>$LOGS_FILE
    validate $? "installing mysql client package"

    mysql -h mysql.pmpkdev.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOGS_FILE
    validate $? "Loading the mysql schema"
}

print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") | Script Executed in: $G $TOTAL_TIME seconds $N" | tee -a $LOGS_FILE
}
