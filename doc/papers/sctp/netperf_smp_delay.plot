set terminal fig color small portrait fontsize 9 inches size 4.5 2.4
set output 'netperf_smp_delay.fig'
set nologscale
set ylabel 'Delay (Seconds per Message)'
set y2label '|'
set xlabel 'Message Size (Bytes)'
set grid x y
set key top left Right noreverse
set xtics nomirror (2048,4096,8192,16384)
set ytics nomirror
set border 3 lw 1
plot \
     'netperf_smp.dat' using 1:(10/$4) smooth unique title "SCTP Streams Tx" with linespoints lt 6,\
     'netperf_smp.dat' using 1:(10/$5) smooth unique title "SCTP Streams Rx" with linespoints lt 5,\
     'netperf_smp.dat' using 1:(10/$6) smooth unique title "TCP Sockets Tx (N)" with linespoints lt 4,\
     'netperf_smp.dat' using 1:(10/$7) smooth unique title "TCP Sockets Rx (N)" with linespoints lt 3,\
     'netperf_smp.dat' using 1:(10/$8) smooth unique title "TCP Sockets Tx (A)" with linespoints lt 11,\
     'netperf_smp.dat' using 1:(10/$9) smooth unique title "TCP Sockets Rx (A)" with linespoints lt 10,\
     'netperf_smp.dat' using 1:(10/$2) smooth unique title "TCP XTIoS Tx"   with linespoints lt 1,\
     'netperf_smp.dat' using 1:(10/$3) smooth unique title "TCP XTIoS Rx"   with linespoints lt 2
