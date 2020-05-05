#!/bin/bash
set -e

DIR=$(dirname $(realpath "$0"))
cd $DIR/src
python3 src_deceases_istat.py
echo ""

echo "ISTAT data analysis finished"
echo "Start Rt analysis."
echo ""

cd ../RealtimeR0_Italy 
python3 RealtimeR0_Italy.py
echo ""
echo "Open two summary plot"
cd .. 
xdg-open ./RealtimeR0_Italy/rt_Italy.png
xdg-open ./plot/covid_italy.png
echo "ALL DONE!"
