#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data
# XXX  : number of grid in longitude
# YYY  : number of grid in latitude (or pressure/height)
# TTT  : total numer of time (daily)
# DDD  : number of days per year
# BYY  : first year (e.g. 1979)
# EYY  : last year (e.g. 2005)
# LYR  : whether the data has leap year or not
#  (e.g. 1 : leap year, 0 : no leap year)
# LNX  : whether the machine is linux or not
#  This is for the record length problem.
#  (e.g. 4 : linux machine, 1 : other machine)
# MMM  : missing value
# PPP  : period of data

 source ../../../env.sh

# for var in olr trmm gpcp sf200_n1 slp_n1 u200 u200_n2 u200_e u850 u850_n2 u850_e u3d_n1 t3d_n1 q3d_n1 om3d_n1
 for var in olr_av u200_n1 u850_n1
 do

 cd $HHH/level_2/comp

# export XXX=144
# export YYY=73
 export TTT=2557
 export DDD=365
 export BYY=1979
 export EYY=1985
 export LYR=1
# export LNX=4
 export MMM=-999.
 export PPP=19790101_19851231

 if [ $var == 'u3d_n1' ] || [ $var == 't3d_n1' ] || [ $var == 'q3d_n1' ] || [ $var == 'om3d_n1']; then
 export YYY=12
 fi

 mkdir -p $var/src
 cd $var/src

 cp -f $HHH/level_2/com/comp/comp.sea.f90.com .

 sed "s#homedir#$HHH#g"       comp.sea.f90.com > tmp2
 sed "s/variable/$var/g"                     tmp2 > tmp1
 sed "s/num_t/$TTT/g"                        tmp1 > tmp2
 sed "s/num_x/$XXX/g"                        tmp2 > tmp1
 sed "s/num_y/$YYY/g"                        tmp1 > tmp2
 sed "s/num_d/$DDD/g"                        tmp2 > tmp1
 sed "s/beg_y/$BYY/g"                        tmp1 > tmp2
 sed "s/end_y/$EYY/g"                        tmp2 > tmp1
 sed "s/leap_year/$LYR/g"                    tmp1 > tmp2
 sed "s/linux_recl/$LNX/g"                   tmp2 > tmp1
 sed "s/dmiss/$MMM/g"                        tmp1 > tmp2
 sed "s/period/$PPP/g"                       tmp2 > comp.sea.f90
 
 $FC comp.sea.f90 
# ifort -assume byterecl comp.sea.f90 
 ./a.out
 rm -f a.out

cd $HHH/level_2/comp/$var

 cp -f $HHH/level_1/$var/data/daily.$PPP.ctl ctl.com
 sed "s/daily.$PPP.gdat/comp.sum.gdat/g" ctl.com > comp.sum.ctl
 sed "s/daily.$PPP.gdat/comp.win.gdat/g" ctl.com > comp.win.ctl

 cp -f $HHH/level_2/com/comp/n_comp.sum.ctl .
 cp -f $HHH/level_2/com/comp/n_comp.win.ctl .
 done

