#!/usr/bin/env bash

# client side pipe aggregator
cat | while read _stdin; do
  _command="${_stdin:0:4}"

  # dump command - sends file lines as chat messages
  if [ "$_command" == "dump" ]; then
    _file_path="${_stdin:5}"
    tail "$_file_path" | while read _line; do
      echo "> $_line"
    done

  # file command - sends a file and returns id for downloading
  # wraps the content in !sof / !eof (see chat.sh commands)
  elif [ "$_command" == "file" ]; then
    _file_path="${_stdin:5}"
    echo "!sof $_file_path"
    tail "$_file_path"
    echo "!eof"
    # tar czf - "$_file_path" | cat

  # if no command recognized just pass stdin
  else
    echo "$_stdin"
  fi
done

exit 0
