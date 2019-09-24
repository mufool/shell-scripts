#!/bin/bash


for line in $(cat temp_data.csv)
do
	#echo $line
	arr=(${line//,/ }) 
	#echo ${arr[@]}
	#echo ${arr[1]}
	md5_value=`echo -n ${arr[0]}|md5sum|cut -d ' ' -f1`
	echo $md5_value ${arr[1]} ${arr[2]} ${arr[3]} ${arr[4]} ${arr[5]}
	#exit;
done
