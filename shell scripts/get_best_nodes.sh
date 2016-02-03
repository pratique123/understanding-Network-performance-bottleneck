#!/bin/bash
#!/bin/bash
#!/bin/sh
sudo -S yum -y install bind-utils > /dev/null 2>&1
sudo -S yum -y install jwhois > /dev/null 2>&1
#sudo -S rpm -ivh sshpass-1.0-0.FC8.i386.rpm 2>/dev/null
sudo -S yum -y install geoip > /dev/null 2>&1
if [ ! -e GeoLiteCity.dat.gz ]
then
sudo -S wget -N http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz > /dev/null 2>&1
echo y|gunzip GeoLiteCity.dat.gz
sudo -S mv GeoLiteCity.dat /usr/share/GeoIP/
fi
DIRECTORY=traceroutetoall
if [ ! -d "$DIRECTORY" ]; then
  # Control will enter here if $DIRECTORY doesn't exist.
mkdir traceroutetoall
fi
file=temporary.txt
cp  Finalnodes_access22.txt traceroutetoall/
cp traceroutinghost.txt traceroutetoall/
cd traceroutetoall
sort -R Finalnodes_access22.txt > Finalnodes_access1.txt ; shuf -o Finalnodes_access2.txt  Finalnodes_access1.txt
if [ -f "$file" ]
then
rm -r $file
#echo "file found and  deleted"
fi
host=`cat traceroutinghost.txt`
while read line;do
if [[ "$line" != "$host" ]]
then
traceroute -n  "$line"| awk 'NR>1' > lado1.txt
host "$line" | grep " has address " > lado2.txt
if [ -s lado2.txt ]
then
cat lado2.txt | awk 'NR==1' >lado3.txt
server=`grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' lado3.txt`
fi
as_no=`whois -h whois.cymru.com  "$server" | tail -n1 | awk '{print $1}'`
#sed -n "/$line/p" lado1.txt > lado2.txt
#sed -n "/$server/p" lado1.txt > lado3.txt
sed -nr /"$server"/p lado1.txt > lado3.txt
if [[ -s lado3.txt ]] ;then
#timetaken=`tail -1 lado2.txt|gawk -v var ="$line" -F var '{print $2}'|awk '{print $2,$3}'`
numberofhops=`tail -1 lado3.txt|awk '{print $1}'`
node=`geoiplookup -f /usr/share/GeoIP/GeoLiteCity.dat "$line"|awk 'NR==1{print $6 $7 $8 $9}'`
echo -e  "$numberofhops\t$as_no\t$line\t$node" >> temporary.txt
#echo "$timetaken"
else
echo "host unreachable"
fi
fi
done < Finalnodes_access2.txt
rm -r lado1.txt lado2.txt Finalnodes_access1.txt Finalnodes_access2.txt lado3.txt
sort -R temporary.txt > temporary1.txt
shuf -o temporary2.txt temporary1.txt
sort -n -r  temporary2.txt > temporary3.txt
rm -r temporary.txt temporary1.txt
while read line1 line2
do
echo -e "$line2\t$line1">> temporary4.txt
done < temporary3.txt
cat  temporary4.txt | awk -F" " '!a[$1]++' > temporary5.txt
numberoffield=`cat temporary5.txt| awk --field-separator=" " "{ print NF }" |tail -n1`
if [ "$numberoffield" -eq 4 ]
then
cat temporary5.txt | awk '{print $2}'> "$host".txt
else
cat temporary5.txt | awk '{print $1}'> "$host".txt
fi
rm -r temporary3.txt temporary2.txt temporary4.txt

