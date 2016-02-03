#!/bin/bash
############### get ip and set path and directory to collect data from #######################
hostip=`curl -s http://whatismijnip.nl |cut -d " " -f 5`
path="/home/diku_INF5510/"
directory ="client"
directory1="server"
path1="/Users/Pratique/main_experiment_result"
echo "$hostip">hostip.txt
echo "$path">path.txt
echo "$path1">path1.txt
echo "$directory">directory.txt
echo "$directory1">directory1.txt
#################### copy the information and relevant shell script to collect data and also run the script to collect data from each host #######################
while read line
do
echo "$line">node.txt
if ssh   -o StrictHostKeyChecking=no   -n -i planetlab-key   -T diku_INF5510@"$line";then
scp -o StrictHostKeyChecking=no -i planetlab-key -r node.txt  getresult_from_remote_host.sh  hostip.txt path1.txt path.txt directory.txt path.txt directory1.txt  diku_INF5510@"$line":"$path" > /dev/null 2>&1
(ssh   -o StrictHostKeyChecking=no    -n -i planetlab-key  -T diku_INF5510@"$line" bash getresult_from_remote_host.sh  'bash -s')& 
fi
done < FinalNodes.txt
