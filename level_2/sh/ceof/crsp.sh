#!/bin/sh
set -vx

# HHH  : home directory
# TTT  : total number of time
# LNX  : whether the machine is linux or not
#  This is for the record length problem.
#  (e.g. 4 : linux machine, 1 : other machine)

 source ../../../env.sh

 export LNX=4
 #export TTT=2557
 export TTT=2556

 for var in ceof
 do

 cd $HHH/level_2/$var

 mkdir -p src/crsp
 cd src/crsp

 cp -f $HHH/level_2/com/ceof/crsp.f90.com .
 cp -f $HHH/tools/fftpack/libfftpack.a .
 cp -f $HHH/level_2/com/ceof/makefile.crsp .

 sed "s#homedir#$HHH#g"    crsp.f90.com > tmp1
 sed "s/mjo_var/$var/g"             tmp1 > tmp2
 sed "s/linux_recl/$LNX/g"          tmp2 > tmp1
 sed "s/num_t/$TTT/g"               tmp1 > crsp.f90

 cp -f makefile.crsp makefile

 make
 ./crsp
 rm -f crsp crsp.f90 crsp.o

# end
 done
