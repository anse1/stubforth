source symbols.gdb

set tdesc filename ./gdb-target.xml
set architecture arm
tar ext :3333
mon reset
mon halt
