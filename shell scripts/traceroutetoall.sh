#!/bin/bash
#!/bin/sh
while read line;
do
	echo "$line">traceroutinghost.txt
	scp  -o StrictHostKeyChecking=no -i  planetlab-key -r Finalnodes_access22.txt   get_best_nodes.sh  traceroutinghost.txt diku_INF5510@"$line": 
 	nohup ssh   -o StrictHostKeyChecking=no    -n -i planetlab-key  -T diku_INF5510@"$line" bash get_best_nodes.sh 'bash -s'&
done < Finalnodes_access22.txt


