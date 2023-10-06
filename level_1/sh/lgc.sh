#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data
# XXX  : number of grid in longitude
# YYY  : number of grid in latitude
# DDD  : number of days per 1 year (for models using 360 day calendar)
# TTT  : number of total time (in day)
# BYY  : first year (e.g. 1979)
# NYR  : number of years (e.g. 27 for 1979-2005)
# NYR1 : NYR - 1
# LYR  : whether the data has leap year or not
#  (e.g. 1 : leap year, 0 : no leap year)
# LNX  : whether the machine is linux or not
#  This is for the record length problem.
#  (e.g. 4 : linux machine, 1 : other machine)
# MMM  : missing value
# PPP  : period of data

# for ctl file
# BLO  : starting longitude
# BLA  : starting latitude
# DLO  : delta longitude
# DLA  : delta latitude

 source ../../env.sh

 for var in olr_av u850_n1 u200_n1
 do

 export DDD=365
# export TTT=2557
 export BYY=1979
 export LYR=1
# export LNX=4
 export MMM=-9.99e8
 export PPP=19790101_19851231

# for ctl file
 export BLO=0.0
 export BLA=-90.0
 export DLO=2.5
 export DLA=2.5

 export NYR=7
 ((NYR1=NYR-1))

 cd $HHH/level_1/$var

# output directory
 mkdir -p lgc

# source directory
 mkdir -p src/lgc
 cd src/lgc

 cp -f $HHH/level_1/com/lgc/input.nml.com .
 cp -f $HHH/level_1/com/lgc/llreg_2d.f90 .

 for exp in east.win east.sum north.io north.wp
 do

  if [ $exp == 'east.win' ]; then
   export XXX=144
   export YYY=1
   export SEA=1
   export NYY=$NYR1
   export REG=10S10N
   export FIL=IO.win
  elif [ $exp == 'east.sum' ]; then
   export XXX=144
   export YYY=1
   export SEA=2
   export NYY=$NYR
   export REG=10S10N
   export FIL=IO.sum
  elif [ $exp == 'north.io' ]; then
   export XXX=1
   export YYY=73
   export SEA=2
   export NYY=$NYR
   export REG=80E100E
   export FIL=IO.sum
  elif [ $exp == 'north.wp' ]; then
   export XXX=1
   export YYY=73
   export SEA=2
   export NYY=$NYR
   export REG=115E135E
   export FIL=IO.sum
  fi

 sed "s#homedir#$HHH#g"  input.nml.com > tmp1
 sed "s/variable/$var/g"             tmp1 > tmp2
 sed "s/num_x/$XXX/g"                tmp2 > tmp1
 sed "s/num_y/$YYY/g"                tmp1 > tmp2
 sed "s/num_d/$DDD/g"                tmp2 > tmp1
 sed "s/num_t/$TTT/g"                tmp1 > tmp2
 sed "s/num_r/$NYY/g"                tmp2 > tmp1
 sed "s/beg_year/$BYY/g"             tmp1 > tmp2
 sed "s/leap_year/$LYR/g"            tmp2 > tmp1
 sed "s/linux_recl/$LNX/g"           tmp1 > tmp2
 sed "s/beg_lon/$BLO/g"              tmp2 > tmp1
 sed "s/beg_lat/$BLA/g"              tmp1 > tmp2
 sed "s/del_lon/$DLO/g"              tmp2 > tmp1
 sed "s/del_lat/$DLA/g"              tmp1 > tmp2
 sed "s/zm/$REG/g"                   tmp2 > tmp1
 sed "s/in_name/$FIL/g"              tmp1 > tmp2
 sed "s/out_name/$exp/g"             tmp2 > tmp1
 sed "s/sea_num/$SEA/g"              tmp1 > tmp2
 sed "s/missing/$MMM/g"              tmp2 > tmp1
 sed "s/period/$PPP/g"               tmp1 > input.nml

 $FC llreg_2d.f90
 ./a.out
 rm -f a.out

 done

 done
