set xlabel "time from start (s)"     #set the x-axis(time)
set ylabel "count"		     #set yhe y-axis(the statistics)
set autoscale
set term png
set output "test.png"		     #set the output file
plot "data.out" using 1:2 with lines title "Number of Chromium processes","data.out" using 1:3 with lines title "Maximum number of threads","data.out" using 1:4 with lines title "Average number of threads per process","data.out" using 1:5 with lines title "Total memory consumption of all processes(RSS-Resident Set Size) in MB","data.out" using 1:6 with lines title "Maximum memory consumption(RSS) per process in MB","data.out" using 1:7 with lines title "Average number of voluntary context switches per process","data.out" using 1:8 with lines title "Average number of non-voluntary context switches per process"
