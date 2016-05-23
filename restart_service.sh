#!/bin/bash

declare -A ServiceHashTable
ServiceHashTable=( ["tv"]="x" ["tap"]="x" ["frs"]="x" ["fb"]="x" ["pg"]="x" ["fops"]="x" ["hinv"]="x" ["ne"]="x" ["nei"]="x" ["hops"]="x" ["tripops"]="x")

isRunning(){
  if ssh $2 ps aux | grep "${ServiceHashTable["$1"]}" | grep -v grep > /dev/null 2>&1
  then
    return 0
  else
    return 1
  fi
}

stop_service(){
  echo "stopping $1"
  command=`ssh $2 stop-$1`
  if [ $? -ne 0 ]; then
    echo "could not execute command:$command"
  else
    echo $command
  fi
}

start_service(){
  echo "starting $1"
  command=`/bin/bash /etc/ansible/playbooks/general/push.sh start $1 $2`
  echo "$command"
  if [ $? -ne 0 ]; then
    echo "could not execute command:$command"
  else
    echo $command
  fi
}

restart_all(){
  echo "restart all at $2"

  for i in "${!ServiceHashTable[@]}"
  do
    if isRunning $1 $2;
    then
      echo "key: $1"
      echo "value: ${ServiceHashTable[$i]}"
      stop_service $1 $2
      sleep 1s
      start_service $1 $2
    fi
  done
}


restart_one(){
  if isRunning $1 $2;
  then 
    echo "$1 is running"
    stop_service $1 $2
  else
    echo "$1 is not running"
  fi
  start_service $1 $2
}

restart_service(){
  if [ "$1" == "all" ]; then
    restart_all $1 $2
  else
    restart_one $1 $2
  fi
}

if [ -z $1 ] || [ $# -ne 2 ]; then
  echo "usage: ./restart.sh (service/all) stagingXX"
else
  restart_service $1 $2
fi
