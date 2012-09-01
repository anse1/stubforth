hex
: scr FFF000 ;
: mrr FFF004 ;
: csgba FFF100 ;
: csgbb FFF102 ;
: csgbc FFF104 ;
: csgbd FFF106 ;
: csa FFF110 ;
: csb FFF112 ;
: csc FFF114 ;
: csd FFF116 ;
: emucs FFF118 ;
: pllcr FFF200 ;
: pllfsr FFF202 ;
: pctlr FFF207 ;
: ivr FFF300 ;
: icr FFF302 ;
: imr FFF304 ;
: isr FFF30C ;
: ipr FFF30C ;
: padir FFF400 ;
: padata FFF401 ;
: papuen FFF402 ;
: pbdir FFF408 ;
: pbdata FFF409 ;
: pbpuen FFF40A ;
: pbsel FFF40B ;
: pcdir FFF410 ;
: pcdata FFF411 ;
: pcpden FFF412 ;
: pcsel FFF413 ;
: pddir FFF418 ;
: pddata FFF419 ;
: pdpuen FFF41A ;
: pdsel FFF41B ;
: pdpol FFF41C ;
: pdirqen FFF41D ;
: pdkben FFF41E ;
: pdiqeg FFF41F ;
: pedir FFF420 ;
: pedata FFF421 ;
: pepuen FFF422 ;
: pesel FFF423 ;
: pfdir FFF428 ;
: pfdata FFF429 ;
: pfpuen FFF42A ;
: pfsel FFF42B ;
: pgdir FFF430 ;
: pgdata FFF431 ;
: pgpuen FFF432 ;
: pgsel FFF433 ;
: pwmc FFF500 ;
: pwms FFF502 ;
: pwmp FFF504 ;
: pwmcnt FFF505 ;
: tctl FFF600 ;
: tprer FFF602 ;
: tcmp FFF604 ;
: tcr FFF606 ;
: tcn FFF608 ;
: tstat FFF60A ;
: spimdata FFF800 ;
: spimcont FFF802 ;
: ustcnt FFF900 ;
: ubaud FFF902 ;
: urx FFF904 ;
: rxdata FFF905 ;
: utx FFF906 ;
: txdata FFF907 ;
: umisc FFF908 ;
: nipr FFF90A ;
: lssa FFFA00 ;
: lvpw FFFA05 ;
: lxmax FFFA08 ;
: lymax FFFA0A ;
: lcxp FFFA18 ;
: lcyp FFFA1A ;
: lcwch FFFA1C ;
: lblkc FFFA1F ;
: lpicf FFFA20 ;
: lpolcf FFFA21 ;
: lacdrc FFFA23 ;
: lpxcd FFFA25 ;
: lckcon FFFA27 ;
: lrra FFFA29 ;
: lposr FFFA2D ;
: lfrcm FFFA31 ;
: lgpmr FFFA33 ;
: pwmr FFFA36 ;
: rtctime FFFB00 ;
: rtcalrm FFFB04 ;
: watchdog FFFB0A ;
: rtcctl FFFB0C ;
: rtcisr FFFB0E ;
: rtcienr FFFB10 ;
: stpwch FFFB12 ;
: dayr FFFB1A ;
: dayalarm FFFB1C ;
: icemcr fffffd0c ;
: icemsr fffffd0e ;
: icemcmr fffffd0a ;
: icemccr fffffd08 ;
: icemamr fffffd04 ;
: icemacr fffffd00 ;

1 0 << constant mspi
1 1 << constant mtmr
1 2 << constant muart
1 3 << constant mwdt
1 4 << constant mrtc
1 6 << constant mkb
1 7 << constant mpwm
1 8 << constant mint0
1 9 << constant mint1
1 10 << constant mint2
1 11 << constant mint3
1 16 << constant mirq1
1 17 << constant mirq2
1 18 << constant mirq3
1 19 << constant mirq6
1 20 << constant mirq5
1 22 << constant msam
1 23 << constant memiq

