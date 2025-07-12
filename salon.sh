#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "Welcome to My Salon, how can I help you?"
  SERVICES=$($PSQL "select service_id, name from services")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
  echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    [1-5]) SET_APPOINTMENT ;;
    [e]) EXIT ;;
    *) MAIN_MENU "I could not find that service. What would you like today?"
  esac
  
}

SET_APPOINTMENT() {
  #ask for phone number, name and insert data into customers table
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  VALID_PHONE_NUM=$($PSQL "select phone from customers where phone ='$CUSTOMER_PHONE'")

  if [[ -z $VALID_PHONE_NUM ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_APPOINTMENT=$($PSQL "insert into customers(name, phone) values ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  else
    CUSTOMER_NAME=$($PSQL "select name from customers where phone ='$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | sed 's/^ *//;s/ *$//')
  fi
  #Retrieve customer_id
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE' and name = '$CUSTOMER_NAME'")
  CUSTOMER_ID=$(echo "$CUSTOMER_ID" | sed 's/^ *//;s/ *$//')
  SET_SERVICE_TIME
}

SET_SERVICE_TIME() {
  FORMATTED_SERVICE=$(echo $SERVICE_ID_SELECTED | sed -E 's/1/cut/g; s/2/color/g; s/3/perm/g; s/4/style/g; s/5/trim/g')
  #ask for desire time for appointment
  echo -e "\nWhat time would you like your $FORMATTED_SERVICE, $CUSTOMER_NAME?"
  read SERVICE_TIME
  #Set appointment
  INSERT_SERVICE=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
  #take service_id

  echo -e "\nI have put you down for a $FORMATTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
} 

EXIT() {
  echo bye
}

MAIN_MENU
