#!/usr/bin/env bash

echo
echo "*******************************"
echo "* Welcome to the netcat chat! *"
echo "*******************************"
echo
echo -n "Pick a room: "
read -r _room
echo -n "Your name: "
read -r _username

_path_room="./rooms/$_room"
_room_log="$_path_room/room.log"
_messages_log="$_path_room/messages.log"

mkdir -p "$_path_room"
touch "$_room_log"
touch "$_messages_log"

echo $(date +"%b %d %H:%M:%S") "$_username joined" >> "$_room_log"

echo
echo "Type your message and press ENTER"
echo "Send exit to leave"
echo
echo "********** [$_room] **********"
echo

((tail -F "$_room_log" | xargs -l echo "RL $1") & (tail -F "$_messages_log" | xargs -l echo "ML $1") & (cat /dev/stdin | xargs -l echo "IN $1")) | while read _line
do
  _target="${_line:0:2}"
  _message=$(echo "${_line:2}" | xargs)
  _date=$(date +"%b %d %H:%M:%S")

  if [ "$_target" == "IN" ] && [ "$_message" == "exit" ] ;
    then
      echo "$_date $_username left" >> "$_room_log"
      echo "Bye!"
      exit 0
  fi

  if [ "$_target" == "IN" ] ;
  then
    echo "$_date [$_username]: $_message" >> "$_messages_log"
  else
    echo "$_message"
  fi
done

exit 0
