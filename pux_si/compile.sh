#!/bin/bash
mkdir -p sim_bin

rm ./sim_bin/clist
touch ./sim_bin/clist

for f in ./rtl/*.v; do
  echo "DETECTED SOURCE FILE: $f"
  echo "$f" >> ./sim_bin/clist
done

for f in ./sim/src/*.v; do
  echo "DETECTED TB FILE: $f"
  echo "$f" >> ./sim_bin/clist
done

iverilog -o"./sim_bin/${PWD##*/}" -c"./sim_bin/clist" -s$1 -D__ICARUS__
