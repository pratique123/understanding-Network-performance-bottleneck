#!/bin/bash
#!/bin/sh
START=`date +%s`
START=$((10#$START))
VAL4=$((START + 11000))
VAL5=0
################### Install the basic programs if not available ###################

if ! type "gcc"> /dev/null 2>&1;then
sudo -S yum -y install gcc > /dev/null 2>&1
fi

sudo -S yum -y  install gcc-objc libobjc gnustep-base-devel gnustep-gui-devel gnustep-g > /dev/null 2>&1
sudo -S yum -y install bind-utils  > /dev/null 2>&1

################# Process the file and save to variable that is needed to run furhter in program ################################
host=`cat host2.txt`
cp host2.txt port1.txt client/
cd client
if [ ! -d "$host" ]
then
mkdir -p "$host"
fi
cp uthash.h client.c client.h host2.txt port1.txt "$host"/
cd "$host"
if [ -e rtt.txt -a -e "$host"_traceroute.txt -a -e top.txt -a -e "$host"_traceroute_as.txt ];then
rm -r rtt.txt "$host"_traceroute.txt "$host"_traceroute_as.txt top.txt
fi
port=`cat port1.txt`
host "$host" | grep "has address"   > lado2.txt
if [ -s lado2.txt ]
then
cat lado2.txt | awk 'NR==1' >lado3.txt
receiver=`grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' lado3.txt`
fi
echo -e "client $port \t$receiver"
gcc -o client client.c > /dev/null 2>&1
nohup ./client "$receiver" "$port" 500  > sendingerror.txt 2>&1 &
pid=`echo "$!"`
####################### loop until a week and iterate per second #######################################
touch file.txt
while [[ $VAL5 -le $VAL4 ]]
do
traceroute_output=` traceroute -n -q 10 "$host"| awk 'NR>1'`
echo "$traceroute_output" >lado1.txt
#top -n 1 -b >> top.txt
#echo $'\n' >> top.txt
date +%s>>top.txt|sudo -S top -b -n 1 | grep "Cpu">>top.txt; sudo -S top -b  -n 1| grep "Mem" >>top.txt; sudo -S top -b -n 1| grep "client">>top.txt; sudo -S top -b -n 1| grep "server">>top.txt
echo "===============================================================================================">>top.txt
sed -nr /"$receiver"/p lado1.txt > lado2.txt

##write rtt to the hostfile
if [[ -s lado2.txt ]] 
then
date +%s>>"$host"_traceroute.txt
tail -1 lado2.txt >> "$host"_traceroute.txt
else
date +%s>>"$host"_traceroute.txt
echo "host unreachable" >> "$host"_traceroute.txt
fi
echo "===============================================================================================">>"host"_traceroute.txt
####################### Parse eachline of the traceroute to generate the path of the routing and time ############################
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
###################### finalize the  counter ########################################################
END=`date +%s`
VAL5="$((10#$END))"
done
rm -r lado1.txt lado2.txt file.txt
kill  -9 "$pid" > /dev/null 2>&1 
################## kill the background process if this is still running ############################

ps aux|grep "client"|awk '{print $2}'>killclient.txt
while read killclient
do
kill -9 "$killclient" > /dev/null 2>&1
done < killclient.txt

if [ -e backgroundprocessid.txt ]
then
rm -r backgroundprocessid.txt
fi
###################### double check if the process is not killed properly kill every single process running at the node############################
cd ..
cd ..
chmod 777 killprocess.sh
./killprocess.sh



echo " The program terminated with success">>Programterminationinfo.txt
