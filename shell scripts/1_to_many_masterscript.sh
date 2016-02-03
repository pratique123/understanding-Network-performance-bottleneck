#!/bin/bash
#!/bin/sh
counter=3000
############### read the node sender and receiver pair from the file and run respective script to each node #########################
while read line1;do
echo "$line1">host1.txt
count=0 
###################### fist loop read the sender name and provides the file name containing the list of the nodes that gonna probe to next loop ##########################
while read line2;do
################# second loop gets file and name of the node that which gone be probed hence form client server pair and runs respective scripts in the nodes ##############3
echo "$line2">host2.txt
if ssh   -o StrictHostKeyChecking=no   -n -i planetlab-key   -T diku_INF5510@"$line1" &&  ssh   -o StrictHostKeyChecking=no   -n -i planetlab-key   -T diku_INF5510@"$line2" > /dev/null 2>&1;then
counter=$((counter+1))
count=$((count+1))
echo "$counter">port1.txt
echo -e  "$line2\t$counter"
if [[ count -le 1 ]]
then
scp -o StrictHostKeyChecking=no -i planetlab-key -r /Users/Pratique/Desktop/copiedclient/client   finalremotescript1.sh host2.txt port1.txt diku_INF5510@"$line1": > /dev/null 2>&1
else
scp  -o StrictHostKeyChecking=no -i planetlab-key -r  host2.txt port1.txt diku_INF5510@"$line1": > /dev/null 2>&1
fi
scp -o StrictHostKeyChecking=no -i planetlab-key -r  /Users/Pratique/Desktop/copiedclient/server   finalremotescript2.sh host1.txt port1.txt diku_INF5510@"$line2": > /dev/null 2>&1
(nohup ssh -o ServerAliveInterval=60  -o StrictHostKeyChecking=no    -n -i planetlab-key  -T diku_INF5510@"$line2"  bash finalremotescript2.sh 'bash -s') &
echo "$!">>backgroundprocessid.txt
 sleep 40
(nohup ssh -o ServerAliveInterval=60  -o StrictHostKeyChecking=no    -n -i planetlab-key  -T diku_INF5510@"$line1"  bash finalremotescript1.sh 'bash -s')&
sleep 20
echo "$!">>backgroundprocessid1.txt
sleep 40
echo -e "$line1\t$counter"
else
echo "sorry couldn't login to both nodes at the same time:"
fi

done < Best_nodes/finalresult/"$line1".txt
done < FinalNodes.txt
