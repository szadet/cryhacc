#!/bin/bash

echo "PROJECT NAME IS ${PWD##*/}"

if [ -x ./sim_bin/${PWD##*/} ]; then
  vvp "./sim_bin/${PWD##*/}"
#  gtkwave ./sim_bin/test.vcd wave.sav
else
  echo "Project not compiled!"
fi
