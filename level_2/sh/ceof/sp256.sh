#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data
# BYY  : first year (e.g. 1979)
# NYR  : number of years (e.g. 27 for 1979-2005)
# LYR  : whether the data has leap year or not
#  (e.g. 1 : leap year, 0 : no leap year)
# LNX  : whether the machine is linux or not
#  This is for the record length problem.
#  (e.g. 4 : linux machine, 1 : other machine)
# PPP  : period of data

 source ../../../env.sh

 for var in ceof
 do

 export BYY=1979
 export LYR=1
# export LNX=4

#@ NYR = 27
 export NYR=7

 cd $HHH/level_2/$var

 mkdir -p src/sp256
 cd src/sp256

 cp -f $HHH/level_2/com/ceof/sp256.f90.com .
 cp -f $HHH/tools/fftpack/libfftpack.a .
 cp -f $HHH/level_2/com/ceof/makefile.sp256 .

 sed "s#homedir#$HHH#g" sp256.f90.com > tmp1
 sed "s/mjo_var/$var/g"           tmp1 > tmp2
 sed "s/num_r/$NYR/g"             tmp2 > tmp1
 sed "s/beg_year/$BYY/g"          tmp1 > tmp2
 sed "s/leap_year/$LYR/g"         tmp2 > tmp1
 sed "s/linux_recl/$LNX/g"        tmp1 > sp256.f90

 cp -f makefile.sp256 makefile
 make
 ./sp256
 rm -f sp256 sp256.o

# end
 done

