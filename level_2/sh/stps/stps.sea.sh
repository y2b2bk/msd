#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data
# XXX  : number of grid in longitude
# TTT  : number of day for one segment
# BYY  : first year (e.g. 1979)
# DDD  : number of days per 1 year (for models using 360 day calendar)
# NYR  : number of years (e.g. 27 for 1979-2005)
# NYR1 : NYR - 1
# LYR  : whether the data has leap year or not
#  (e.g. 1 : leap year, 0 : no leap year)
# LNX  : whether the machine is linux or not
#  This is for the record length problem.
#  (e.g. 4 : linux machine, 1 : other machine)
# PPP  : period of data

 source ../../../env.sh

 for var in olr u850 u200
 do

 export XXX=144
 export TTT=180
 export BYY=1979
 export DDD=365
 export LYR=1
 export LNX=4
 export PPP=19790101_19851231

#@ NYR = 27
 export NYR=7
#@ NYR1 = $NYR - 1
 ((NYR1=NYR-1))

 if [ $var == 'olr' ]; then
 export CCC=6
 elif [ $var == 'u850' ]; then
 export CCC=7
 elif [ $var == 'u200' ]; then
 export CCC=7
 fi

 for sea in win sum 
 do

  if [ $sea == 'win' ]; then
   export SEA=1
   export NYY=$NYR1
  elif [ $sea == 'sum' ]; then
   export SEA=2
   export NYY=$NYR
  fi

 mkdir -p $HHH/level_2/stps
 cd $HHH/level_2/stps
 mkdir -p $sea/$var
 cd $sea/$var

 cp -f $HHH/level_2/com/stps/stps.sea.f90.com .
 cp -f $HHH/tools/fftpack/libfftpack.a .
 cp -f $HHH/level_2/com/stps/makefile .

 sed "s#homedir#$HHH#g"  stps.sea.f90.com > tmp1
 sed "s/variable/$var/g"              tmp1 > tmp2
 sed "s/num_x/$XXX/g"                 tmp2 > tmp1
 sed "s/num_t/$TTT/g"                 tmp1 > tmp2
 sed "s/num_r/$NYY/g"                 tmp2 > tmp1
 sed "s/num_d/$DDD/g"                 tmp1 > tmp2
 sed "s/beg_year/$BYY/g"              tmp2 > tmp1
 sed "s/leap_year/$LYR/g"             tmp1 > tmp2
 sed "s/linux_recl/$LNX/g"            tmp2 > tmp1
 sed "s/sea_num/$SEA/g"               tmp1 > tmp2
 sed "s/num_cha/$CCC/g"               tmp2 > tmp1
 sed "s/period/$PPP/g"                tmp1 > stps.f90

 
 make
 ./stps
 rm -f stps

# end
 done

# end
 done
