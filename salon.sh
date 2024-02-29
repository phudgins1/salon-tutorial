#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t -c"
echo -e "\n~~~~~ My Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo $1
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi
  SERVICES=$($PSQL "select service_id, name from services");
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SCHEDULE_SERVICE $SERVICE_ID_SELECTED
  fi
}

SCHEDULE_SERVICE() {
  if [[ -z $1 ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # find service
    SERVICE_ID=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
    # if service not found
    if [[ -z $SERVICE_ID ]]
    then
      # return to main menu
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      # get customer phone
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
      # if customer not found
      if [[ -z $CUSTOMER_ID ]]
      then
        # get customer name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        # create customer
        CUSTOMER_CREATE_RESULT=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
      # format service prompt
      CUSTOMER_NAME=$($PSQL "select name from customers where customer_id=$CUSTOMER_ID")
      SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID")
      echo -e "\nWhat time would you like your$SERVICE_NAME,$CUSTOMER_NAME?"
      read SERVICE_TIME
      APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
      if [[ $APPOINTMENT_RESULT = "INSERT 0 1" ]]
      then
        echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
