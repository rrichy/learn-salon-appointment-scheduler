#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_SERVICE() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo "Welcome to My Salon, how can I help you?"
  fi

  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")

  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    if [[ $SERVICE_ID =~ ^[0-9]+$ ]]
    then
      echo "$SERVICE_ID) $NAME"
    fi
  done
  read SERVICE_ID_SELECTED

  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME_SELECTED ]]
  then
    MAIN_SERVICE "I could not find that service. What would you like today?"
  else
    DO_SERVICE $SERVICE_ID_SELECTED $SERVICE_NAME_SELECTED
  fi
}

DO_SERVICE() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    INSERT_INTO_CUSTOMERS=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  CUSTOMER_NAME_TRIMMED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')

  echo -e "\nWhat time would you like your $2, $CUSTOMER_NAME_TRIMMED?"
  read SERVICE_TIME

  INSERT_INTO_APPOINTMENTS=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $1, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $2 at $SERVICE_TIME, $CUSTOMER_NAME_TRIMMED."
}

MAIN_SERVICE
