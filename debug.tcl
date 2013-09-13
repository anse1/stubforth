#!/usr/bin/expect

# Wait for echos so we don't overflow the buffers.

set timeout 1

set tty [lindex $argv 0]
spawn -open [set port [open $tty "r+"]]

send "fffff9070155\n"
expect -re "fffff9070155U\n"

# @utx_data <- 0x55
send "FFFFFFAA0A4E7111FC0055F9074E71\nFFFFFFAA00\n"
expect -re "FFFFFFAA00U\n"

# lea utx_data, %a2
send "FFFFFFAA084E7145F8F9074E71\nFFFFFFAA00\n"
expect -re "FFFFFFAA00\n"

# movb #0x55, %a2@
send "FFFFFFAA084E7114BC00554E71\nFFFFFFAA00\n"
expect -re "FFFFFFAA00U\n"

# moveb #'V', %d7
send "FFFFFFAA084E711E3C00564E71\nFFFFFFAA00\n"
expect -re "FFFFFFAA00\n"

#	movb %d7, %a2@
#	lsr #8, %d7
#       nop
send "FFFFFFAA084E711487E04F4E71\nFFFFFFAA00\n"
expect -re "FFFFFFAA00V\n"


# # 	lea 0, %a1
# # 	nop
# send "FFFFFFAA084E7143F800044E71\nFFFFFFAA00\n"
# expect -re "FFFFFFAA00\n"


# send "0000000401AA\n"



# lea 0x12345678, %a2
# FFFFFFAA084E7145F912345678
# FFFFFFAA00

# lea 0x12345678, %a3
# FFFFFFAA084E7147F912345678
# FFFFFFAA00

