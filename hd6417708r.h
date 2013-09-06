#ifndef HD6417708R_H
#define HD6417708R_H

#define SCTDR ((volatile unsigned char *)0xfffffe86)
#define SCRDR ((volatile unsigned char *)0xfffffe8a)

#define SCSSR ((volatile unsigned char *)0xfffffe88)

#define TDRE (1<<7)
#define RDRF (1<<6)

#define PCTR ((volatile unsigned short *)0xffffff76)
#define PDTR ((volatile unsigned char *)0xffffff78)
#define SCSPTR ((volatile unsigned char *)0xffffff7C)

#endif
