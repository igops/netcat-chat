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
_path_files="$_path_room/files"

mkdir -p "$_path_room"
mkdir -p "$_path_files"
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

_file_write_mode=false
_file_write_name=""

(
  (tail -F "$_messages_log" -n 10 | sed "s/^/ML /" -u) &
  (cat | sed "s/^/IN /" -u)
) | while read _line
do
  _target="${_line:0:2}"
  _message="${_line:3}"
  _date=$(date +"%b %d %H:%M:%S")

  # file write in progress
  if [ "$_file_write_mode" = true ] ;
  then
    if [[ "$_message" == "!eof" ]] ;
    then
      echo "ok"
      echo "$_date $_username sent a file [$_file_write_name]" >> "$_messages_log"

      _file_write_mode=false
      _file_write_name=""
    else
      echo "$_message" >> "$_path_files/$_file_write_name"
    fi

  # incoming stdin ("IN some_string")
  elif [ "$_target" == "IN" ] ;
  then
    # exit command - exits the chat
    if [[ "$_message" == exit* ]] ;
    then
      echo "$_date $_username left" >> "$_messages_log"
      echo
      echo "bye!"
      exit 0

    # find command - searches the messages by a query
    elif [[ "$_message" == find* ]] ;
    then
      _query="${_message:5}"
      echo
      echo "search results for [$_query] in the room [$_room]:"
      grep "$_query" "$_messages_log" | sed "s/^/> /"
      echo "eof search results"
      echo

    # !sof command - file start marker, processes the file until !eof is met
    elif [[ "$_message" == "!sof"* ]] ;
    then
      _client_file_name="${_message:5}"
      echo
      echo "sending file [$_client_file_name]"
      _file_write_mode=true
      _file_write_name="$(cat /proc/sys/kernel/random/uuid)"
      touch "$_path_files/$_file_write_name"

    # load command - downloads a file by id
    elif [[ "$_message" == load* ]] ;
    then
      _query="${_message:5}"
      echo
      echo "a file matching [$_query] in the room [$_room]:"
      echo
      cat "$_path_files/$_query"*
      echo "eof"
      echo

    # no command recognized - just add it to log
    else
      echo "$_date [$_username]: $_message" >> "$_messages_log"
    fi

  # room broadcast ("ML some_string")
  else
    echo "$_message"
  fi
done

exit 0
