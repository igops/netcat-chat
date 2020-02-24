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
_messages_log="$_path_room/messages.log"

mkdir -p "$_path_room"
touch "$_messages_log"

echo $(date +"%b %d %H:%M:%S") "$_username joined" >> "$_messages_log"

echo
echo "********** [$_room] **********"
echo
echo "Type your message and press ENTER"
echo "Use [find %query%] to search for messages, e.g. [find Feb 24]"
echo "Use [exit] to leave"
echo
echo "Showing last 10 messages"
echo

(
  (tail -F "$_messages_log" -n 10 | sed "s/^/ML /" -u) &
  (cat | sed "s/^/IN /" -u)
) | while read _line
do
  _target="${_line:0:2}"
  _message="${_line:3}"
  _date=$(date +"%b %d %H:%M:%S")

  # incoming stdin ("IN some_string")
  if [ "$_target" == "IN" ] ;
  then
    # special commands
    if [[ "$_message" == exit* ]] ;
    then
      echo "$_date $_username left" >> "$_messages_log"
      echo "Bye!"
      exit 0

    elif [[ "$_message" == find* ]] ;
    then
      _query="${_message:5}"
      echo
      echo "  Search results for [$_query] in the room [$_room]:"
      echo
      grep "$_query" "$_messages_log" | sed "s/^/> /"
      echo
      echo "  EOF Search results"
      echo

    # not special command - just add it to log
    else
      echo "$_date [$_username]: $_message" >> "$_messages_log"
    fi

  # room broadcast ("ML some_string")
  else
    echo "$_message"
  fi
done

exit 0
