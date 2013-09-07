#ifndef HD6417708R_H
#define HD6417708R_H

#define SCSMR ((volatile unsigned char *)0xFFFFFE80)   //  Serial mode register
#define SCBRR ((volatile unsigned char *)0xFFFFFE82)   //  Bit rate register
#define SCSCR ((volatile unsigned char *)0xFFFFFE84)   //  Serial control register
#define SCTDR ((volatile unsigned char *)0xFFFFFE86)   //  Transmit data register
#define SCSSR ((volatile unsigned char *)0xFFFFFE88)   //  Serial status register
#define SCRDR ((volatile unsigned char *)0xFFFFFE8A)   //  Receive data register
#define SCSPTR ((volatile unsigned char *)0xFFFFFF7C)   //  Serial port register

#define TDRE (1<<7)
#define RDRF (1<<6)
#define TEND (1<<2)


#define PCTR ((volatile unsigned short *)0xffffff76)
#define PDTR ((volatile unsigned char *)0xffffff78)

#endif
