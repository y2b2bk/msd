#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data
# XXX  : number of grid in longitude
# YYY  : number of grid in latitude
# TTT  : total numer of time (daily)
# LNX  : whether the machine is linux or not
#  This is for the record length problem.
#  (e.g. 4 : linux machine, 1 : other machine)
# MMM  : missing value
# PPP  : period of data

# NOR  : name of olr data
# NU8  : name of u850 data
# NU2  : name of u200 data

# for ctl file
# BLO  : starting longitude
# DLO  : delta longitude

 source ../../../env.sh

 export XXX=144
 export YYY=1
 export TTT=2557
# export LNX=4
 export MMM=-999.
# export PPP 19790101_20051231
 export PPP=19790101_19851231

 export NOR=olr_av
 export NU8=u850_n1
 export NU2=u200_n1

 export BLO=0.0
 export DLO=5.0

 for var in ceof 
 do

# output directory
 mkdir -p $HHH/level_2/$var
 cd $HHH/level_2/$var

# source directory
 mkdir -p src
 cd src

# cp -f $HHH/level_2/com/ceof/ceof.f.com .
 cp -f $HHH/level_2/com/ceof/ceof.f90.com .

 sed "s#homedir#$HHH#g"  ceof.f90.com > tmp1
 sed "s/variable/$var/g"          tmp1 > tmp2
 sed "s/num_x/$XXX/g"             tmp2 > tmp1
 sed "s/num_y/$YYY/g"             tmp1 > tmp2
 sed "s/num_t/$TTT/g"             tmp2 > tmp1
 sed "s/olr_name/$NOR/g"          tmp1 > tmp2
 sed "s/u850_name/$NU8/g"         tmp2 > tmp1
 sed "s/u200_name/$NU2/g"         tmp1 > tmp2
 sed "s/linux_recl/$LNX/g"        tmp2 > tmp1
 sed "s/missing/$MMM/g"           tmp1 > tmp2
 sed "s/period/$PPP/g"            tmp2 > ceof.f90

 #f90 ceof.f
 $FC ceof.f90
 ./a.out 
 rm -f a.out
 pwd

 cd $HHH/level_2/$var
# cp -f /jdata4/cdl/kim/msm/level_2/com/ceof/ts.ctl .
 cp -f $HHH/level_2/com/ceof/ts.ctl .
# cp -f /jdata4/cdl/kim/msm/level_2/com/ceof/ts.pr.ctl .
 cp -f $HHH/level_2/com/ceof/ts.pr.ctl .
# cp -f /jdata4/cdl/kim/msm/level_2/com/ceof/ceof.pct.ctl .
 cp -f $HHH/level_2/com/ceof/ceof.pct.ctl .
# cp -f /jdata4/cdl/kim/msm/level_2/com/ceof/ev.ctl.com .
 cp -f $HHH/level_2/com/ceof/ev.ctl.com .

 sed "s/num_x/$XXX/g"     ev.ctl.com > tmp1
 sed "s/beg_lon/$BLO/g"            tmp1 > tmp2
 sed "s/del_lon/$DLO/g"            tmp2 > tmp1
 sed "s/missing/$MMM/g"            tmp1 > ev.ctl

# end
 done
