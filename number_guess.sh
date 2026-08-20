#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read NAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$NAME';")

if [[ -z $USER_ID ]]
then
  INSERT_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$NAME');")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$NAME';")
  echo "Welcome, $NAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID;")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID;")
  echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$((RANDOM % 1000 + 1))
GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"

while true
do
  read GUESS

  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  GUESS_COUNT=$((GUESS_COUNT + 1))

  if [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done

$PSQL "UPDATE users SET games_played = games_played + 1, best_game = CASE WHEN best_game IS NULL OR $GUESS_COUNT < best_game THEN $GUESS_COUNT ELSE best_game END WHERE user_id=$USER_ID;"
$PSQL "INSERT INTO games(user_id, secret_number, guesses) VALUES($USER_ID, $SECRET_NUMBER, $GUESS_COUNT);"
