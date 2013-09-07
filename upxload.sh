set -ex

T=/dev/ttyUSB0
stty -F $T 115200

# delete all firmware slots
# echo -n xfd0y > $T
# echo -n xfd1y > $T

echo -n s0 > $T
stty -F $T 230400

echo -n xu > $T
< $T  > $T sx -t 10 $1

echo -n s0 > $T
stty -F $T 115200
