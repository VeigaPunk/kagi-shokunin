set -e
TREE=$1; ROOT=$2; OUT=$3; FEED=$4; FEEDURL=$5; OBSAT=$6
python3 -I -B observe-runner.py "$TREE" "$ROOT" "$OUT" "$FEED" "$FEEDURL" "$OBSAT"
