#!/bin/bash
sudo -S rpm -ivh sshpass-1.0-0.FC8.i386.rpm >/dev/null 2>&1
############################# gather information that is sent by remote host for further processing ####################
$host=`cat hosip.txt`
$path=`cat path.txt`
$path1=`cat path1.txt`
$directory=`cat directory.txt`
$directory1=`cat directory1.txt`
$node=`cat node.txt`
############ name the compressed file along with the timestamp ########################
$filename=$node_$(date "+%Y.%m.%d-%H.%M.%S").tar.gz
cd $path
tar -czvf $filename  $directory $directory1 > /dev/null 2>&1
######################### COpy results to the remote host #################################
ssh -o "StrictHostKeyChecking no" -o "PasswordAuthentication no" "$host" > /dev/null 2>&1
sshpass -p "godkrishna12" scp -o StrictHostKeyChecking=no -r $filename  pratique@"$host":$path1/"$node" 
rm -r $filename
cd client
###################### get the name of the all node probed by current node ###########################
dirs=(/client/*/)
for dir in "${dirs[@]}"
do
    echo "$dir">>client_directory.txt
done
############## delete the files to avoid exceed the disk quota #############################
while read line
do
cd $line
rm -r rtt.txt top.txt $line_traceroute.txt $line_traceroute_as.txt
cd ..
done < client_directory.txt
rm -r client_directory.txt
cd ..
cd server
########### get list of all the node  which probed the current node ########################
dirs=(/server/*/)
for dir in "${dirs[@]}"
do
    echo "$dir">>server_directory.txt
done
############## delete the files to avoid exceed the disk quota #############################
while read line1
do
cd $line1
rm -r receiving_info.txt  top.txt $line1_traceroute.txt $line1_traceroute_as.txt
cd ..
done < server_directory.txt
rm -r server_directory.txt
cd ..




