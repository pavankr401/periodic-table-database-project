#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

SEND_MESSAGE(){
  INPUT=$1
  if [[ -z $INPUT ]]
  then
    echo Please provide an element as an argument.
    return;
  fi

  case $INPUT in
    [0-9]|[0-9][0-9]) SEARCH_WITH_ATOMIC_NUMBER ;;
    [A-Z]|[A-Z][a-z]) SEARCH_WITH_SYMBOL ;;
    *) SEARCH_WITH_NAME ;;
  esac
}

SEARCH_WITH_ATOMIC_NUMBER()
{
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number='$INPUT'")
    if [[ -z $ATOMIC_NUMBER ]]
    then
      echo "I could not find that element in the database."
    else
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
      NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER")

      GET_MESSAGE $ATOMIC_NUMBER
    fi
}

SEARCH_WITH_SYMBOL()
{
   SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE symbol = '$INPUT'")
    if [[ -z $SYMBOL ]]
    then 
      echo "I could not find that element in the database."
    else
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol LIKE '$INPUT';")
      NAME=$($PSQL "SELECT name FROM elements WHERE symbol='$INPUT';")

      GET_MESSAGE $ATOMIC_NUMBER
    fi
}

SEARCH_WITH_NAME()
{
  NAME=$($PSQL "SELECT name FROM elements WHERE name='$INPUT';")
    if [[ -z $NAME ]]
    then
      echo "I could not find that element in the database."
    else
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name LIKE '$INPUT';")
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name = '$INPUT'")

      GET_MESSAGE $ATOMIC_NUMBER
    fi
}

GET_MESSAGE()
{
  GET_ELEMENT_INFO=$($PSQL "SELECT * FROM properties WHERE atomic_number = $1")
  echo "$GET_ELEMENT_INFO" | while IFS=" | " read ATOMIC_NUM ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE_ID
  do
  TYPE=$($PSQL "SELECT type FROM types WHERE type_id = $TYPE_ID")
  SYMBOL=$(echo "$SYMBOL" | sed 's/ //')

  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius." | sed -E 's/ +/ /g'
  done
}
SEND_MESSAGE $1
