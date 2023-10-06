#!/bin/sh

# HHH  : home directory
# var  : name of data
# XXX  : number of grid in longitude
# DDD  : number of days per 1 year (for models using 360 day calendar)
# BYY  : first year (e.g. 1979)
# NYR  : number of years (e.g. 27 for 1979-2005)
# LYR  : whether the data has leap year or not
#  (e.g. 1 : leap year, 0 : no leap year)
# LNX  : whether the machine is linux or not
#  This is for the record length problem.
#  (e.g. 4 : linux machine, 1 : other machine)
# PPP  : period of data
# CCC  : number of character for $var
#  (e.g. CCC = 7 for u850_n1)

 source ../../../env.sh

 for var in olr u850 u200
 do

 mkdir -p $HHH/level_2/stps
 cd $HHH/level_2/stps

 mkdir -p all/$var
 cd all/$var

 cp -f $HHH/level_2/com/stps/stps.all.f90.com .
# cp -f $HHH/level_2/com/stps/libfftpack.a .
 cp -f $HHH/tools/fftpack/libfftpack.a .
 cp -f $HHH/level_2/com/stps/makefile .

 export XXX=144
 export TTT=364
# export TTT 2557
# export NYR 27
 export NYR=7
 export DDD=365
 export BYY=1979
 export LYR=1
# export LNX 1
 export LNX=4
# export PPP 19790101_20051231
 export PPP=19790101_19851231

 if [ $var == 'olr' ]; then
 export CCC=6
 elif [ $var == 'u850' ]; then
 export CCC=7
 elif [ $var == 'u200' ]; then
 export CCC=7
 fi

 sed "s#homedir#$HHH#g"  stps.all.f90.com > tmp1
 sed "s/variable/$var/g"              tmp1 > tmp2
 sed "s/num_t/$TTT/g"                 tmp2 > tmp1
 sed "s/num_x/$XXX/g"                 tmp1 > tmp2
 sed "s/num_r/$NYR/g"                 tmp2 > tmp1
 sed "s/num_d/$DDD/g"                 tmp1 > tmp2
 sed "s/beg_year/$BYY/g"              tmp2 > tmp1
 sed "s/leap_year/$LYR/g"             tmp1 > tmp2
 sed "s/linux_recl/$LNX/g"            tmp2 > tmp1
 sed "s/num_cha/$CCC/g"               tmp1 > tmp2
 sed "s/period/$PPP/g"                tmp2 > stps.f90
 
 rm -f stps
 make
 ./stps
 rm -f stps

# end
 done
