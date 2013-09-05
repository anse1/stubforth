
spawn  /bin/bash ./upxload.sh cv.upx

expect {
    "0/ 0kRetry 0: Cancelled"  { exit 3 }
    "9/ 1kRetry 0: Timeout on sector ACK" { exit 1 }
    "11/ 1k" { exit 2 }
}
