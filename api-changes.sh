#!/bin/bash
#ACB

printf "enter current branch release: " 
read -r current_branch
printf "enter last week branch release: "
read -r last_week_branch

git --git-dir=/home/adi/tools/repository/.git --work-tree=/home/adi/tools/repository diff $current_branch $last_week_branch | grep +++ | grep api | grep -v impl | grep -v build.gradle | grep -v '/erp' | grep -v '/test/' | grep -v '/marketing/' | grep -v '/api/v1' | grep -v '/processing/' | grep -v '/hotel-extranet/' | grep -v 'Accessor.java'
