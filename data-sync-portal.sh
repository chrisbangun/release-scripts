#!/bin/bash


declare -A commands
commands=( ["sync_config_command_util"]="/sync-config" ["sync_data_to_staging"]="/sync-data" ["dump"]="/dump" )

function welcome {
  echo " USAGE: "
  echo "        /sync-config production instance"
  echo "        /sync-config stagingXX Domain"
  echo "        /sync-data stagingXX <DB_NAME> <COLLECTION>"
  echo "        /dump <DB_NAME>"
}

function sync_config_prod_mongoscript02 {
  #sync all the configs
  ssh mongoscript02 "mongo < /home/ubuntu/mongo-dump/config-sync-script/mongodata-config-sync.js" < /dev/null
  ssh mongoscript02 "mongo < /home/ubuntu/mongo-dump/config-sync-script/mongocache-config-sync.js" < /dev/null
  ssh mongoscript02 "mongo < /home/ubuntu/mongo-dump/config-sync-script/geodata-mongod-config-sync.js" < /dev/null
  ssh mongoscript02 "mongo < /home/ubuntu/mongo-dump/config-sync-script/mongofb-config-sync.js" < /dev/null
  ssh mongoscript02 "mongo < /home/ubuntu/mongo-dump/config-sync-script/hdata-mongod-config-sync.js" < /dev/null
  ssh mongoscript02 "mongo < /home/ubuntu/mongo-dump/config-sync-script/mongodwh-config-sync.js" < /dev/null
  ssh mongoscript02 "mongo < /home/ubuntu/mongo-dump/config-sync-script/mongohnet-config-sync.js" < /dev/null
  ssh mongoscript02 "mongo < /home/ubuntu/mongo-dump/config-sync-script/mongohotel-config-sync.js" < /dev/null
  ssh mongoscript02 "mongo < /home/ubuntu/mongo-dump/config-sync-script/mongosdim-config-sync.js" < /dev/null
  ssh mongoscript02 "mongo < /home/ubuntu/mongo-dump/config-sync-script/mongostrack-config-sync.js" < /dev/null
}

function sync_config_staging {
  # mongodump --db=<old_db_name> --collection=<collection_name> --out=data/
  # mongorestore --db=<new_db_name> --collection=<collection_name> data/<db_name>/<collection_name>.bson

  STAGING=${command_arr[1]}
  DOMAIN=${command_arr[2]}
  bash ./sync-config.sh $STAGING $DOMAIN
  exit
}

function sync_data_to_staging {
  echo $command_arr
  if [ -z "${command_arr[1]}" ]; then
    echo "ERRORL staging parameter is required"
    echo "usage : "
    echo "  sync-mongo.sh <STAGING_NAME>"
    echo "  STAGING_NAME : "
    echo "    staging06"
    echo "    staging19"
    echo "    <<all available staging>>"
    exit
  fi

  if [ -z "${command_arr[2]}" ]; then
    echo "ERROR : db parameter is required"
    echo "usage : "
    echo "  sync-mongo.sh <STAGING_NAME> <DB_NAME>"
    echo "  DB_NAME : "
    echo "    <<all other database you want to sync>>"
    exit
  fi

  if [ -z "${command_arr[3]}" ]; then
    bash ./sync-mongoscript-to-staging.sh ${command_arr[1]} ${command_arr[2]}
    exit
  fi

  if [ -z "${command_arr[4]}" ]; then
    bash ./sync-mongoscript-to-staging.sh ${command_arr[1]} ${command_arr[2]} ${command_arr[3]}
    exit
  fi
}

function dump {
  echo "here"
  db=${command_arr[1]}
  ssh mongoscript02 "bash /home/ubuntu/mongo-dump/mongodump-script.sh $db" < /dev/null
}

function sync_config_command_util {
  if [[ ${command_arr[1]} == *"staging"* ]]; then
    sync_config_staging ${command_arr[1]} ${command_arr[2]}
  elif [[ ${command_arr[1]} == *"production"* ]]; then
    sync_config_prod_mongoscript02
  fi
}

input_command=""

while [ "$input_command" != "done" ] && [ "$input_command" != "exit" ]
do
  welcome
  read -p "> " input_command;
  command_arr=($input_command)
  sync_config="/sync-config"
  sync_data="/sync-data"
  dump="/dump"

  for funct in "${!commands[@]}"
  do
    if [ "${commands[$funct]}" == "${command_arr[0]}" ]; then
      $funct $command_arr
    fi
  done

done
