/* This file is included in the VM's scope after all platform
   independent words have been defined.
   "boot" will be looked up by name on boot, so it is possible to
   redefine it here to initialize hardware, extend the dictionary from
   ROM, etc. */

primary(syscall)
{
  volatile register vmint callno asm ("%rax") = sp[-1].i;
  volatile register vmint arg0	 asm ("%rdi") = sp[-2].i;
  volatile register vmint arg1	 asm ("%rsi") = sp[-3].i;
  volatile register vmint arg2	 asm ("%rdx") = sp[-4].i;
  volatile register vmint arg3	 asm ("%r10") = sp[-5].i;
  volatile register vmint arg4	 asm ("%r8") = sp[-6].i;
  volatile register vmint arg5	 asm ("%r9") = sp[-7].i;

    asm("syscall"
	: "=r" (callno)
	: "r" (callno), "r"(arg0), "r"(arg1), "r"(arg2), "r"(arg3), "r"(arg4), "r"(arg5)
	: "r11", "rcx", "memory"
	);
  sp[-1].i = callno;
}
