#!/bin/bash
#!/bin/ssh
START=`date +%s`
START=$((10#$START))
VAL4=$((START + 11000))
VAL5=0

if ! type "gcc"> /dev/null 2>&1;then
sudo -S yum -y install gcc > /dev/null 2>&1
fi

if ! type "lsof"> /dev/null 2>&1;then
sudo -S yum -y install lsof > /dev/null 2>&1
fi

sudo -S yum -y  install gcc-objc libobjc gnustep-base-devel gnustep-gui-devel gnustep-g > /dev/null 2>&1
sudo -S yum -y install bind-utils  > /dev/null 2>&1
####################### ######## parse the relevant information from file ########################
host=`cat host1.txt`
port=`cat port1.txt`
cp host1.txt port1.txt server/
host "$host"| grep " has address " > lado2.txt
if [ -s lado2.txt ]
then
cat lado2.txt | awk 'NR==1' >lado3.txt
sender=`grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' lado3.txt`
fi

echo -e  "server port$port \t$sender"
cd server
if [ ! -d  "$host" ]
then
mkdir -p  "$host"
fi
cp server.c server.h host1.txt port1.txt  "$host"/
cd "$host"
gcc -o server server.c > /dev/null 2>&1
nohup ./server "$port" > servererror.txt 2>&1 &  
pid=`echo "$!"`
touch file.txt
########## loop for a week and iterate every second ########################
while [[ $VAL5 -le $VAL4 ]]
do
traceroute_output=` traceroute -n -q 10 "$host"| awk 'NR>1'`
echo "$traceroute_output" > lado1.txt 
date +%s>>top.txt|sudo -S top -b -n 1 | grep "Cpu">>top.txt; sudo -S top -b  -n 1| grep "Mem" >>top.txt; sudo -S top -b -n 1| grep "client">>top.txt; sudo -S top -b -n 1| grep "server">>top.txt
echo "===============================================================================================">>top.txt
sed -nr /"$sender"/p lado1.txt > lado2.txt

############## write rtt to the hostfile#############################
if [[ -s lado2.txt ]]
then
date +%s>>"$host"_traceroute.txt
tail -1 lado2.txt >> "$host"_traceroute.txt
else
date +%s>>"$host"_traceroute.txt
echo "host unreachable" >> "$host"_traceroute.txt
fi
echo "===============================================================================================">>"host"_traceroute.txt
##################### Parse eachline of the traceroute to generate the path of the routing and time####################################
date +%s>>"$host"_traceroute_as.txt
echo "===========================================================">>"$host"_traceroute_as.txt
while read line1;do
date +%s>>"$host"_traceroute_as.txt
echo "$line1">file.txt
ip_add=`grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' file.txt`
as_no=`whois -h whois.cymru.com  "$ip_add" | awk 'NR==4{print $1}'`
while read f1 f2 f3 f4 ;do
echo -e  "$as_no\t$f3\t$f4" >> "$host"_traceroute_as.txt
done < file.txt
done < lado1.txt
echo "===========================================================">>"$host"_traceroute_as.txt
#rm -r file.txt
##final counter
END=`date +%s`
VAL5="$((10#$END))"
done
##############remove the used file not needed now ###################################

rm -r lado1.txt lado2.txt file.txt 
kill -9 "$pid" > /dev/null 2>&1
#################### killl bakground proccess if running still #########################
ps aux | grep "server" > process.txt
while read line;
do
kill -9 "$line" > /dev/null 2>&1
echo "$line is killed in server"
#echo "the id of backgroundprocess =$line" 
done < process.txt
if [[ -e "backgroundprocessid.txt" ]]
then
rm -r backgroundprocessid.txt
fi
killport=$(lsof -t -i:"$port") 
if ps -p "$killport" > /dev/null 2>&1 
then
kill -9 "$killport" > /dev/null 2>&1 
fi
##########double check and kill every process incase the process is not killed properly above ######################
cd ..
cd ..
chmod 777 killprocess.sh
./killprocess.sh

echo "program terminated with success" >>programtermination_info.txt

