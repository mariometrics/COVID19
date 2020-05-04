#!/bin/bash
set -e

DIR=$(dirname $(realpath "$0")) 	# locate this sh-script

cd $DIR/src
echo "Changed Directory to ${DIR}"

python3 src_deceases_istat.py
