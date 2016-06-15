#!/bin/bash

declare -a commands=("/sync-config" "/sync-data" "/dump")

function welcome {
  echo " USAGE: "
  echo "        /sync-config production mongoscript02"
  echo "        /sync-config stagingXX Domain"
  echo "        /sync-data stagingXX DB [collection]"
  echo "        /dump <DB_NAME> e.g. traveloka-data"
}


function sync_config_prod_mongoscript02 {
  #haven't been tested
  #sync all the configs
  ssh mongoscript02 "mongo < mongodata-config-sync.js" < /dev/null
  ssh mongoscript02 "mongo < mongocache-config-sync.js" < /dev/null
  ssh mongoscript02 "mongo < mongofb-config-sync.js" < /dev/null
  #TO DO
  # create more js for config sync from production to mongoscript02
  echo "sync_config_prod_mongoscript02 is called"
  exit
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
    echo "    traveloka-asset"
    echo "    traveloka-data"
    echo "    traveloka-agent"
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

answer=""
array_length=${#commands[@]}
welcome

while [ "$answer" != "done" ] && [ "$answer" != "exit" ]
do
  read -p "> " input_command;
  command_arr=($input_command)
  sync_config="/sync-config"
  sync_data="/sync-data"
  dump="/dump"

  if [[ ${command_arr[0]} == ${sync_data} ]]; then
    sync_data_to_staging $command_arr
  elif [[ ${command_arr[0]} == ${sync_config} ]]; then
    sync_config_command_util $command_arr
  elif [[ ${command_arr[0]} == ${dump} ]]; then
    dump $command_arr
  else
    exit
  fi

done
