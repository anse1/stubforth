set -ex

# delete all firmware slots
# echo -n xfd0y > $1
# echo -n xfd1y > $1

echo -n s0 > $1
stty -F $1 230400

echo -n xu > $1
< $1  > $1 sx -t 10 $2

echo -n g > $1
stty -F $1 115200

