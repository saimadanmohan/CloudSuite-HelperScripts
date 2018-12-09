#!/bin/bash
low=10000
hi=200000
delta=10000
while [ $low -le $hi ]
do
  rps=$[low]
  low=$[low+delta]
  ./loader -a ../twitter_dataset/twitter_dataset_30x -s docker_servers.txt -g 0.8 -t 120 -T 30 -c 200 -w 8 -e -r $rps
done
