#!/bin/bash

videoServerIp="$1"
hostFileName="$2"  
remoteOutputPath="$3"
numClientsPerHost="$4"

totalMinNumSessions="$5"
totalMaxNumSessions="$6"

if [ $# -ne 6 ]; then
  echo "Usage: launch_hunt_bin.sh <video_server_ip> <host_list_file> <remote_output_path> <num_clients_per_host> <min_num_sessions> <max_num_sessions>"
  exit 
fi

# Distribute the load
numHosts=$(wc -l < $hostFileName)
numTotalClients=$[$numHosts*$numClientsPerHost]
minNumSessions=$[$totalMinNumSessions/$numTotalClients]
maxNumSessions=$[$totalMaxNumSessions/$numTotalClients]

echo "Total clients = $numTotalClients"
echo "Minimum number of sessions = $minNumSessions"
echo "Maximum number of sessions = $maxNumSessions"

benchmarkSuccess=1

outputDir="/output"
backUpStdoutDir="/output-stdout"

rm -rf "$outputDir/*" "$backUpStdoutDir"
mkdir -p "$outputDir" "$backUpStdoutDir"

# Launches remote with the specified number of sessions. 
# Sets benchmarkSuccess to 1 or 0 depending on success/failure
function launchRemote () {
  totalConns=0
  totalErrors=0
  
  numSessions="$1"
  rate=$[numSessions/10]
  $(dirname $0)/launch_remote.sh $videoServerIp $hostFileName $remoteOutputPath $numClientsPerHost $numSessions $rate
  if [ $? -ne 0 ]; then
    echo 'Failed launching remote... exiting.'
    exit
  fi
  # Open each file in output directory
  for outputFile in $outputDir/*;
  do
    numConns="$(grep 'Total: connections' $outputFile | awk '{print $3}')"
    numErrors="$(grep 'Errors: total' $outputFile | awk '{print $3}')"
    totalConns=$[totalConns+numConns]
    totalErrors=$[totalErrors+numErrors]
  done
  percFailure=$[$totalErrors*100/$totalConns]
  echo "Total connections = $totalConns"
  echo "Total errors = $totalErrors"
  echo "Percentage failure = $percFailure"
  if [ "$percFailure" -gt 5 ]; then
    cp $backUpStdoutDir/* $outputDir
    sleep 10
    benchmarkSuccess=0
  else
    cp $outputDir/* $backUpStdoutDir
    benchmarkSuccess=1
  fi
}
  
# 4 * sessions = Connections
lowLimSessions=25 #lower limit
hiLimSessions=500 #upper limit
delta=25
while [ $lowLimSessions -le $hiLimSessions ]
do
  numSessions=$[lowLimSessions]
  launchRemote $numSessions
  lowLimSessions=$[lowLimSessions+delta]
  if [ $benchmarkSuccess -eq 1 ]
  then
    echo "Benchmark succeeded for $numSessions sessions"
  else
    echo "Benchmark failed for $numSessions sessions"
  fi

done
