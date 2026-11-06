#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if an argument is provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  # Determine if input is a number, symbol, or name
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    QUERY="atomic_number = $1"
  elif [[ ${#1} -le 2 ]]
  then
    QUERY="symbol = INITCAP('$1')"
  else
    QUERY="name = INITCAP('$1')"
  fi

  # Query the database for element details
  ELEMENT_DETAILS=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements JOIN properties USING(atomic_number) JOIN types USING(type_id) WHERE $1 = atomic_number OR symbol ILIKE '$1' OR name ILIKE '$1';")

  # Check if element exists
  if [[ -z $ELEMENT_DETAILS ]]
  then
    echo "I could not find that element in the database."
  else
    # Read the query output using the pipe delimiter
    echo "$ELEMENT_DETAILS" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done
  fi
fi
