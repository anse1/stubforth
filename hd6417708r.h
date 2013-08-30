#ifndef HD6417708R_H
#define HD6417708R_H

#define SCTDR ((volatile unsigned char *)0xfffffe86)
#define SCRDR ((volatile unsigned char *)0xfffffe8a)

#define SCSSR ((volatile unsigned char *)0xfffffe88)

#define TDRE (1<<7)
#define RDRF (1<<6)

#endif
