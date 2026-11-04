#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  if [[ -n $1 ]]
  then 
    echo -e "\n$1"
  fi

  echo -e "\nWelcome to My Salon, how can I help you?"

  echo "$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")" | while IFS='|' read service_id name
  do 
    echo "$service_id) $name"
  done
  
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then 
    MAIN_MENU "I could not find that service. What would you like today?"
    return
  fi

  if [[ -z $SERVICE_ID_SELECTED ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else 
    SHOP_SECTION $SERVICE_ID_SELECTED
  fi
}

SHOP_SECTION(){
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $1")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    VERIFY_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ -z $VERIFY_PHONE ]]
    then 
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME 
    else
        CUSTOMER_NAME=$($PSQL "SELECT name from customers WHERE phone = '$VERIFY_PHONE'")
    fi

    echo -e "\nWhat time would you like your cut, '$CUSTOMER_NAME'"
    read SERVICE_TIME 

    CUSTOMER_DATA_INSERT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$VERIFY_PHONE'")

    APPT_DATA_INSERT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME',$CUSTOMER_ID, $SERVICE_ID)")
    
    echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU