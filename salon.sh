#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

LIST_OF_SERVICES() {
  # Show list of services
  LIST_OF_SERVICES=$($PSQL "SELECT * FROM services")


  echo "$LIST_OF_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done  
}

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  LIST_OF_SERVICES

  # Show list of services
  LIST_OF_SERVICES=$($PSQL "SELECT * FROM services")

  # Get input which services
  read SERVICE_ID_SELECTED

  # search in table services if there is matching data
  SERVICE_AVAILABLE_OR_NOT=$($PSQL "SELECT * FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # while condition input is empty or input is not number 
  while [[ -z $SERVICE_ID_SELECTED || ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ || -z $SERVICE_AVAILABLE_OR_NOT ]]
  do
    echo -e "\nI could not find that service. What would you like today?"

    LIST_OF_SERVICES

    # Get input which services
    read SERVICE_ID_SELECTED

    # search in table services if there is matching data
    SERVICE_AVAILABLE_OR_NOT=$($PSQL "SELECT * FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  done

  if [[ ! -z $SERVICE_AVAILABLE_OR_NOT ]]
  then
    # get phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    
    # get customer data
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # get service name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    if [[ -z $CUSTOMER_NAME ]]
    then
      # No customer data, ask name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # Insert data customer
      CUSTOMERS_INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

      # Insert data success
      if [[ $CUSTOMERS_INSERT_RESULT == "INSERT 0 1" ]]
      then
        # Get time for appointment
        echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME

        # Get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        # Insert data appointment
        APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

        # Send output if inserted success
        if [[ $APPOINTMENT_INSERT_RESULT == "INSERT 0 1" ]]
        then
          echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
        fi
      fi
    else
      # Get time for appointment
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME

      # Get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # Insert data appointment

      APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      # Send output if inserted success
      if [[ $APPOINTMENT_INSERT_RESULT == "INSERT 0 1" ]]
      then
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
      fi
    fi
  fi
}

MAIN_MENU