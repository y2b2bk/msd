#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data
# NYR  : number of year
# XXX  : number of grid in longitude
# YYY  : number of grid in latitude
# SXX  : number of grid in longitude (selected)
# SYY  : number of grid in latitude (selected)
# NGR  : number of selected grid = SXX*SYY
#  NGR should be changed if there are missing data
# JPY  : number of skipped grid in latitude
# DDD  : number of days per 1 year (for models using 360 day calendar)
# TTT  : number of total time (in day) - total period
# BYY  : first year (e.g. 1979)
# NYR  : number of years (e.g. 27 for 1979-2005)
# NYR1 : NYR - 1
# LYR  : whether the data has leap year or not
#  (e.g. 1 : leap year, 0 : no leap year)
#  (0 : no leap year for 360 day calendar model)
# LNX  : whether the machine is linux or not
#  This is for the record length problem.
#  (e.g. 4 : linux machine, 1 : other machine)
# MMM  : missing value

# for ctl file
# BLO  : starting longitude
# BLA  : starting latitude
# DLO  : delta longitude
# DLA  : delta latitude

 source ../../env.sh

 for var in olr_av u850_n1 u200_n1
 do

 export XXX=72
 export YYY=37
# export YYY 35
 export SXX=72
 export SYY=13
 export JPY=12
 export NGR=936
 export DDD=365
# export TTT 9862
 export TTT=2557
 export BYY=1979
 export LYR=1
# export LNX=4
# export MMM -999.
 export MMM=-9.99e8
# export PPP 19790101_20051231
 export PPP=19790101_19851231

 export BLO=0.0
 export BLA=-30.0
 export DLO=5.0
 export DLA=5.0

#@ NYR = 27
 export NYR=7
#@ NYR1 = $NYR - 1
 ((NYR1=NYR-1))

 if [ $var == 'u850_n1' ]; then
  export SYY=9
  export NGR=648
  export JPY=14
  export BLA=-20.0
 fi

 cd $HHH/level_1/$var

# output directory
 mkdir -p eof/sum
 mkdir -p eof/win

# source directory
 mkdir -p src/eof

 for sea in win sum 
 do

 cd $HHH/level_1/$var/src/eof

 cp -f $HHH/level_1/com/eof/eof.f90.com .

 sed "s#homedir#$HHH#g"             eof.f90.com > tmp1
 sed "s/variable/$var/g"                    tmp1 > tmp2
 
 if [ $sea == 'win' ]; then 
 sed "s/num_r/$NYR1/g"                      tmp2 > tmp1
 sed "s/sea_num/1/g"                        tmp1 > tmp2
 sed "s/season/$sea/g"                      tmp2 > tmp1
 elif [ $sea == 'sum' ]; then 
 sed "s/num_r/$NYR/g"                       tmp2 > tmp1
 sed "s/sea_num/2/g"                        tmp1 > tmp2
 sed "s/season/$sea/g"                      tmp2 > tmp1
 fi

 sed "s/num_x/$XXX/g"                       tmp1 > tmp2
 sed "s/num_y/$YYY/g"                       tmp2 > tmp1
 sed "s/sel_x/$SXX/g"                       tmp1 > tmp2
 sed "s/sel_y/$SYY/g"                       tmp2 > tmp1
 sed "s/num_d/$DDD/g"                       tmp1 > tmp2
 sed "s/num_t/$TTT/g"                       tmp2 > tmp1
 sed "s/beg_y/$BYY/g"                       tmp1 > tmp2
 sed "s/num_grid/$NGR/g"                    tmp2 > tmp1
 sed "s/beg_lat/$BLA/g"                     tmp1 > tmp2
 sed "s/num_jump/$JPY/g"                    tmp2 > tmp1
 sed "s/leap_year/$LYR/g"                   tmp1 > tmp2
 sed "s/linux_recl/$LNX/g"                  tmp2 > tmp1
 sed "s/missing/$MMM/g"                     tmp1 > tmp2
 sed "s/period/$PPP/g"                      tmp2 > eof.f90

 $FC eof.f90
 ./a.out
 rm -f a.out

 cd $HHH/level_1/$var/eof/$sea

 cp -f $HHH/level_1/com/eof/ts.ctl .
 cp -f $HHH/level_1/com/eof/ts.pr.ctl .
 cp -f $HHH/level_1/com/eof/eof.pct.ctl .
 cp -f $HHH/level_1/com/eof/ev.ctl.com .

 sed "s/sel_x/$SXX/g"     ev.ctl.com > tmp1
 sed "s/sel_y/$SYY/g"              tmp1 > tmp2
 sed "s/beg_lon/$BLO/g"            tmp2 > tmp1
 sed "s/beg_lat/$BLA/g"            tmp1 > tmp2
 sed "s/del_lon/$DLO/g"            tmp2 > tmp1
 sed "s/del_lat/$DLA/g"            tmp1 > tmp2
 sed "s/missing/$MMM/g"            tmp2 > ev.ctl

# season
 done

# var
 done
