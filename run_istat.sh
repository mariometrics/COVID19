#!/bin/bash
set -e

DIR=$(dirname $(realpath "$0"))
cd $DIR/src
python3 src_deceases_istat.py
