#!/bin/bash
if [ -z "$1" ]; then
  echo "ERROR: staging parameter is required"
  echo "Usage: "
  echo "  sync-config.sh <STAGING_NAME>"
  echo "  STAGING_NAME: "
  echo "  staging06"
  echo "  staging19"
  echo "  <<all available staging machines>>"
  exit
fi

if [ -z "$2" ]; then
  echo "ERROR: domain parameter is required"
  echo "Usage: "
  echo "  sync-config.sh <STAGING_NAME> <DOMAIN>"
  echo "  DOMAIN: "
  echo "  flight"
  echo "  hotel"
  echo "  all"
  exit
fi

INPUT_CONFIG_FILE=config.csv
STAGING=$1
INPUT_DOMAIN=$2

if [ ! -f $INPUT ]; then
  echo "ERROR: file $INPUT does not exist"
  echo "       please specify the file containing list of config collections"
  exit
fi

echo "input summary:"
echo "  staging machine: $STAGING"
echo "  config file $INPUT_CONFIG_FILE"
echo "  config file $INPUT_DOMAIN"
echo "  please make sure all collections are exist at Mongoscript02"
echo "  more detail can be found here: https://29022131.atlassian.net/wiki/display/traveloka/Production+Data+Sync"
echo "  "

function sync_all {
  while IFS=, read db collection domain host
  do
    echo "INFO:sync a collection: $collection from DB:$db":
    ssh $STAGING "mkdir -p /home/ubuntu/mongo-dump/dump/$db" < /dev/null

    echo "INFO:copying data ${db} ${collection} from mongoscript02 to local (ansible01)"
    scp mongoscript02:/home/ubuntu/mongo-dump/dump/$db/$collection.bson $db/$collection.bson

    echo "mongoscript02:/home/ubuntu/mongo-dump/dump/$db/$collection.bson $db"
    scp mongoscript02:/home/ubuntu/mongo-dump/dump/$db/$collection.metadata.json $db/$collection.metadata.json

    echo "INFO:copying data ${db} ${collection} from local (ansible01) to ${STAGING}"
    scp $db/$collection.bson $STAGING:/home/ubuntu/mongo-dump/dump/$db
    scp $db/$collection.metadata.json $STAGING:/home/ubuntu/mongo-dump/dump/$db

    echo "INFO:inserting data to mongodb at ${STAGING}"
    ssh $STAGING "mongorestore --drop /home/ubuntu/mongo-dump/dump/$db --username traveloka --password traveloka" < /dev/null
  done < $INPUT_CONFIG_FILE

}

function dump_collection {
  col="collection"
  ssh mongoscript02 "bash /home/ubuntu/mongo-dump/mongodump-script.sh $col $db $collection" < /dev/null #run dump-script.sh at Mongoscript02
}

function sync_per_domain {
  while IFS=, read db collection domain host
  do
    shopt -s nocasematch
    if [[ $domain == *$INPUT_DOMAIN* ]]; then
      echo "INFO:dumping collection: $collection from DB:$db"
      dump_collection $db $collection

      echo "INFO:sync a collection: $collection from DB:$db":
      ssh $STAGING "rm -r /home/ubuntu/mongo-dump/dump/$db" < /dev/null
      ssh $STAGING "mkdir -p /home/ubuntu/mongo-dump/dump/$db" < /dev/null

      echo "INFO:copying data ${db} ${collection} from mongoscript02 to local (ansible01)"
      scp mongoscript02:/home/ubuntu/mongo-dump/dump/$db/$collection.bson $db/$collection.bson
      scp mongoscript02:/home/ubuntu/mongo-dump/dump/$db/$collection.metadata.json $db/$collection.metadata.json

      echo "INFO:copying data ${db} ${collection} from local (ansible01) to ${STAGING}"
      scp $db/$collection.bson $STAGING:/home/ubuntu/mongo-dump/dump/$db
      scp $db/$collection.metadata.json $STAGING:/home/ubuntu/mongo-dump/dump/$db

      echo "INFO:inserting data to mongodb at ${STAGING}"
      ssh $STAGING "mongorestore --drop /home/ubuntu/mongo-dump/dump/$db --username traveloka --password traveloka" < /dev/null
    fi
  done < $INPUT_CONFIG_FILE
}

if [ $INPUT_DOMAIN == "all" ]; then
  sync_all
else
  sync_per_domain
fi
