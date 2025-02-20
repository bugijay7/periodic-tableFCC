#!/bin/bash

# Check if an argument is provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Define the PSQL command
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Determine whether input is a number (atomic_number) or a string (symbol/name)
if [[ $1 =~ ^[0-9]+$ ]]; then
  QUERY_CONDITION="atomic_number = $1"
else
  QUERY_CONDITION="symbol = '$1' OR name = '$1'"
fi

# Query the database
ELEMENT_INFO=$($PSQL "SELECT atomic_number, name, symbol, atomic_mass, melting_point_celsius, boiling_point_celsius 
FROM elements 
JOIN properties USING(atomic_number) 
WHERE $QUERY_CONDITION;")

# Trim leading/trailing whitespace
ELEMENT_INFO=$(echo "$ELEMENT_INFO" | xargs)

# Check if the query returned a result
if [[ -z $ELEMENT_INFO ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

# Parse the database output
IFS="|" read -r ATOMIC_NUMBER NAME SYMBOL MASS MELT BOIL <<< "$ELEMENT_INFO"

# Correctly formatted output
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a nonmetal, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
