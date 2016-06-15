#!/bin/bash

function dump_specific_table {
  rm -r ./dump/$1
  mongodump --db $1 --out ./dump
  cd dump
  for dir in */
  do
    base=$(basename "$dir")
    if [ "$base" == "$1" ]; then
      tar -czf "${base}.tar.gz" "$dir"
    fi
  done
}

function dump_all {
  rm -r dump
  mongodump --out ./dump
  cd dump
  for dir in */
  do
    base=$(basename "$dir")
    tar -czf "${base}.tar.gz" "$dir"
  done
}

function dump_collection {
  db=$2
  collection=$3
  mongodump --db=$db --collection=$collection --out=./dump
}

if [ "$#" -ge 1 ]; then
  shopt -s nocasematch
  if [[ $1 == *"collection"* ]]; then
    dump_collection $2 $3
  else
    dump_specific_table $1
  fi
else
  dump_all
fi
