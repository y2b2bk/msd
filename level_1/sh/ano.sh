#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data
# XXX  : number of grid in longitude
# YYY  : number of grid in latitude
# TTT  : number of total time (in day)
# SSS  : number(in julian) of the first day in the first year
#  (e.g. SSS should be 4 if the data starts from 4th of January)
# DDD  : number of days per 1 year (for models using 360 day calendar)
# EEE  : number(in julian) of the last day in the last year
# BYY  : first year (e.g. 1979)
# EYY  : last year (e.g. 2005)
# LYR  : whether the data has leap year or not
#  (e.g. 1 : leap year, 0 : no leap year)
# LNX  : whether the machine is linux or not
#  This is for the record length problem.
#  (e.g. 4 : linux machine, 1 : other machine)
# MMM  : missing value
# PPP  : period of data

 source ../../env.sh

 for var in olr_av u850_n1 u200_n1
 do

# export XXX=144
# export YYY=73
 export TTT=2557
 export SSS=1
 export DDD=365
 export EEE=365
 export BYY=1979
 export EYY=1985
 export LYR=1
# export LNX=4
 export MMM=-9.99e8
 export PPP=19790101_19851231

 cd ${HHH}/level_1/$var

 mkdir -p src/ano
 cd src/ano

 cp -f ${HHH}/level_1/com/ano/ano.f90.com .

 sed "s#homedir#$HHH#g"           ano.f90.com > tmp1
 sed "s/variable/$var/g"                    tmp1 > tmp2
 sed "s/num_x/$XXX/g"                       tmp2 > tmp1
 sed "s/num_y/$YYY/g"                       tmp1 > tmp2 
 sed "s/num_t/$TTT/g"                       tmp2 > tmp1 
 sed "s/num_s/$SSS/g"                       tmp1 > tmp2 
 sed "s/num_d/$DDD/g"                       tmp2 > tmp1 
 sed "s/num_e/$EEE/g"                       tmp1 > tmp2 
 sed "s/beg_y/$BYY/g"                       tmp2 > tmp1 
 sed "s/end_y/$EYY/g"                       tmp1 > tmp2 
 sed "s/leap_year/$LYR/g"                   tmp2 > tmp1 
 sed "s/linux_recl/$LNX/g"                  tmp1 > tmp2 
 sed "s/missing/$MMM/g"                     tmp2 > tmp1 
 sed "s/period/$PPP/g"                      tmp1 > ano.f90
 #endif

 $FC ano.f90
 ./a.out
 rm -f a.out

 cd $HHH/level_1/$var/data

 sed "s/daily/daily.clim/g" daily.$PPP.ctl > daily.clim.$PPP.ctl
 sed "s/daily/daily.anom/g" daily.$PPP.ctl > daily.anom.$PPP.ctl
 
 done
