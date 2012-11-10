
set $udr = ((char *)0x4000C000)
set $uartdr = $udr + 0x000
set $uartrsr = $uartecr = $udr + 0x004
set $uartfr = $udr + 0x018
set $uartilpr = $udr + 0x020
set $uartibrd = $udr + 0x024
set $uartfbrd = $udr + 0x028
set $uartlcrh = $udr + 0x02C
set $uartctl = $udr + 0x030
set $uartifls = $udr + 0x034
set $uartim = $udr + 0x038
set $uartris = $udr + 0x03C
set $uartmis = $udr + 0x040
set $uarticr = $udr + 0x044
set $uartdmactl = $udr + 0x048
set $uartlctl = $udr + 0x090
set $uartlss = $udr + 0x094
set $uartltim = $udr + 0x098
set $uart9bitaddr = $udr + 0x0A4
set $uart9bitamask = $udr + 0x0A8
set $uartpp = $udr + 0xFC0
set $uartcc = $udr + 0xFC8

mem 0x40000000 0x80000000 rw

