#!/bin/bash

checkdata() {
 count=0
 while read line3 # Read a line
 do
if [ "$line3" = "$2" ]
then
  count=1
 fi
 done < "$3"
if [ "$count" -ne 1 ] && [ "$counter" -le 4 ]
then
echo "$1" >>finalresult/"$2.txt"
counter=$((counter+1))
echo "$counter"
fi

}

if [ ! -d Best_nodes ]
then
mkdir Best_nodes
fi

cp Finalnodes_access22.txt  Best_nodes/
#cd /Users/Pratique/Final_tracerouting_node
#cp *.txt  /Users/Pratique/Best_nodes/
#cd ..
cd Best_nodes
if [  -d finalresult ]
then
sudo rm -r finalresult
mkdir finalresult
else
mkdir finalresult
fi
sort -r Finalnodes_access22.txt > Finalnodes.txt
while read line
do
counter=0
echo $line
if [ -s "$line.txt" ] && [ -e "$line.txt" ]
then
while read line1
do
if [ -s "$line1.txt" ] && [ -e "$line1.txt" ]
then
checkdata "$line1" "$line" "$line1.txt" " $counter"
#else
#echo "$line1 empty or not availabe while searching inside files"
fi
done < "$line".txt
#else
#echo "$line file empty or  not found while searching main file"
fi
done < Finalnodes.txt

