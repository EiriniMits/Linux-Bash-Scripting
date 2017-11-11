#!/bin/bash
# Eirini Mitsopoulou - Konstantina Papadopoulou


#The function "myfunc1()" is the script execution preperation. It allows everyone to read, write and execute the files below.
myfunc1(){	
	touch output.txt	#contains the number of processes of each time and all the pids									
	chmod 777 "output.txt"
	touch output2.txt	#contains information about all active chromium processes
	chmod 777 "output2.txt"
	touch output3.txt	#It copies specific columns from output2.txt
	chmod 777 "output3.txt"					
	touch output4.txt	#inform when all the processes have terminated
	chmod 777 "output4.txt"
	touch data.out						
	echo 0 > output4.txt	#write 0 in the file which means that the processes haven't terminated yet.
	chmod 777 "data.out"
	pkill -9 "chromium"	#terminates any chromium process is running
}

#The function "myfunc2()" manages the processes.
myfunc2(){
filename="url.in"
while read -r line	#read url.in file
do	 				
	chromium-browser $line & 2>/dev/null	#Calling Chromium with argument the corresponding url
	sleep 5s						#sleep 5 seconds
done < "$filename"
sleep 30s							
echo "----------------------------------------"
echo "List of PIDS about processes in Chromium"	
echo "----------------------------------------"
pgrep chromium  #print a list of all the pids about chromium
	
while pgrep "[c]hromium" &>/dev/null	#until there is no remaining processes, that belong to Chromium
do 
	pkill -n -9 "chromium"			#Terminating (kill -9) the process.
	sleep 5s						
done
echo 1 > output4.txt	#write 1 in the file which means that the processes have terminated 
}

#The function "myfunc3()" is the function of recording statistics. It creates every 0.5 seconds a list of processes belonging in Chromium and calculates the statistics below.
myfunc3(){
time=0
bool=$(head -n 1 output4.txt)
while [  $bool == 0 ]; #while chromium processes are running
do
   	$echo pgrep -c chromium > output.txt	#write the number of processes in output.txt
   	$echo pgrep chromium >> output.txt	#write the pids of processes in output.txt output.txt		
	echo -n "$time " >> data.out		#The 1st column in data.out is the time.
	time=$(echo "$time + 0.5" | bc)		#The time increases by 0.5 seconds.
	firstline=$(head -n 1 output.txt)		
	echo -n "$firstline " >> data.out		#write the number of processes in data.out
	$echo ps -eLF | grep "[c]hromium" > output2.txt		#The information of all processes are stored in the file output2.txt
	$echo awk '{ print $2,$6,$8 }' output2.txt > output3.txt	#copy columns 2 (pid), 6 (threads) and 8 (RSS) from output2.txt to output3.txt
	filenamee="output3.txt"
	sum=0
	sum2=0
	max=0
	max2=0
	pid=0
	while read -r output3    #Reading output3.txt
	do      						
		IFS=', ' read -r -a array <<< "$output3" #array[0] is the current pid, array[1] is the number of threads of the current pid,array[2] is the RSS of it
		if [ "${array[0]}" != "$pid" ] ; then #If array[0] is differrent from the previous pid 	
			if [[ ${array[1]} -gt $max ]]; then #find the max number of threads
	     			max=${array[1]}
	 		fi 
			if [[ ${array[2]} -gt $max2 ]]; then #find the max number of RSS
	     			max2=${array[2]}
	 		fi
        		sum=$(($sum+${array[1]})) #the sum of all threads
			sum2=$(($sum2+${array[2]})) #the sum of all rss
			pid=${array[0]}	#the pid takes the name of the current pid of this loop 			
   		fi
	done < "$filenamee"
	if [ "$firstline" != 0 ] ; then		#calculate the avg number of threads
		p=$(awk "BEGIN {printf \"%.2f\",${sum}/${firstline}}")		
	else		#If the number of processes is 0, then the avg number is 0 too.
		p=0
	fi
	echo -n "$max " >> data.out	#write the max number of threads in data.out.
	echo -n "$p " >> data.out       #write the avg number of threads in data.out.
	ssum2=$(awk "BEGIN {printf \"%.2f\",${sum2}/1000}")	#Convert KB to MB
	echo -n "$ssum2 " >> data.out	 #write the sum of all RSS in data.out
	mmax2=$(awk "BEGIN {printf \"%.2f\",${max2}/1000}")	
	echo -n "$mmax2 " >> data.out	#write the max number of RSS in data.out

	i=1
	sum5=0
	sum6=0
	filename="output.txt"
	while read -r pid         
	do
		test $i -eq 1 && ((i=i+1)) && continue	#Ignore the first line, because we want the pids	
		$echo cat /proc/$pid/status &>/dev/null > output3.txt 	#For each pid write its information in file output3.txt
		s5=$(sed '40q;d' output3.txt)	#Save lines 40 and 41 from the file output3.txt in the variables s5 and s6				
		s6=$(sed '41q;d' output3.txt)
		if [ -z "$s5" ]; then		#if it's empty(zombie pid) continue with another loop
			continue
		fi
		IFS=': ' read -r -a array <<< "$s5" # read the value of the line		
		sum5=$(($sum5+${array[1]}))	#sum voluntary 
		IFS=': ' read -r -a array <<< "$s6"		
		sum6=$(($sum6+${array[1]}))	#sum of non-voluntary 
	done < "$filename"
	if [ "$firstline" != 0 ] ; then		#calculate the avg number of voluntary and non-voluntary context switches 								
		c=$(awk "BEGIN {printf \"%.2f\",${sum5}/${firstline}}")
		n_c=$(awk "BEGIN {printf \"%.2f\",${sum6}/${firstline}}")
	else	    
		c=0
		n_c=0
	fi
	echo -n "$c " >> data.out  #write the 2 final columns of data.out.				
	echo "$n_c " >> data.out				

	sleep 0.5s				
	bool=$(head -n 1 output4.txt) #check if all the processes have terminated		   		
done 
rm output.txt	#delete all the output files	   					
rm output2.txt		   					
rm output3.txt		   					
rm output4.txt		   					
}

#The function "myfunc4()" creates graphs using gnuplot application
myfunc4(){
gnuplot myscript.gp		#Executing myscript.gp using gnuplot application
}

#The functions above, are executing with the following term
myfunc1
myfunc3&	#Execution in the background
myfunc2
myfunc4
