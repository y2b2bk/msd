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

# for ctl file
# BLO  : starting longitude
# BLA  : starting latitude
# DLO  : delta longitude
# DLA  : delta latitude

 source ../../env.sh

 for var in olr_av u850_n1 u200_n1
 do

# export XXX=144
# export YYY=73
 export TTT=2557
 export SSS=1
 export EEE=365
 export DDD=365
 export BYY=1979
 export EYY=1985
 export LYR=1
# export LNX=4
 export MMM=-9.99e8
 export PPP=19790101_19851231

# for ctl file
 export BLO=0.0
# export BLA -90.0
 export BLA=-87.5
 export DLO=2.5
 export DLA=2.5

 cd $HHH/level_1/$var

# output directory
 mkdir -p var

# source directory
 mkdir -p src/var
 cd src/var

 cp -f $HHH/level_1/com/var/var.f90.com .

 sed "s#homedir#$HHH#g"           var.f90.com > tmp1
 sed "s/variable/$var/g"                    tmp1 > tmp2
 sed "s/num_x/$XXX/g"                       tmp2 > tmp1
 sed "s/num_y/$YYY/g"                       tmp1 > tmp2
 sed "s/num_t/$TTT/g"                       tmp2 > tmp1
 sed "s/num_s/$SSS/g"                       tmp1 > tmp2
 sed "s/num_e/$EEE/g"                       tmp2 > tmp1
 sed "s/num_d/$DDD/g"                       tmp1 > tmp2
 sed "s/beg_y/$BYY/g"                       tmp2 > tmp1
 sed "s/end_y/$EYY/g"                       tmp1 > tmp2
 sed "s/leap_year/$LYR/g"                   tmp2 > tmp1
 sed "s/linux_recl/$LNX/g"                  tmp1 > tmp2
 sed "s/missing/$MMM/g"                     tmp2 > tmp1
 sed "s/period/$PPP/g"                      tmp1 > var.f90

 $FC var.f90
 ./a.out
 rm -f a.out
 
 cd $HHH/level_1/$var/var

 cp -f $HHH/level_1/com/var/var.ctl.com .

 for dd in raw fil
 do
 for ss in all sum win
 do

 sed "s/data/$dd/g"   var.ctl.com > tmp1
 sed "s/num_x/$XXX/g"           tmp1 > tmp2
 sed "s/num_y/$YYY/g"           tmp2 > tmp1
 sed "s/beg_lon/$BLO/g"         tmp1 > tmp2
 sed "s/beg_lat/$BLA/g"         tmp2 > tmp1
 sed "s/del_lon/$DLO/g"         tmp1 > tmp2
 sed "s/del_lat/$DLA/g"         tmp2 > tmp1
 sed "s/missing/$MMM/g"         tmp1 > tmp2
 sed "s/season/$ss/g"           tmp2 > $dd.$ss.ctl

 done
 done

 done
