
for ((i=0; i<256;i++)); do
    let m=1024*$i ;
    printf '%08X100000%08X0000\n' $m $m ; done > /dev/ttyUSB0
for ((i=0; i<256;i++)); do
    let m=1024*$i ;
    LC_ALL=C expect readaddr.tcl  /dev/ttyUSB0   $(printf %08X $m) < /dev/null
done
