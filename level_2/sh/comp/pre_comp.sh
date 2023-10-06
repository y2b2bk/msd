#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data
# TTT  : total numer of time (daily)
# LNX  : whether the machine is linux or not
#  This is for the record length problem.
#  (e.g. 4 : linux machine, 1 : other machine)
# MMM  : missing value
# PPP  : period of data

 source ../../../env.sh

 for var in ceof 
 do

 export TTT=2557
# export LNX=4
 export MMM=-999.

 export SN1=1
 export SN2=-1

 mkdir -p $HHH/level_2/comp/data

 mkdir -p $HHH/level_2/comp/$var/src
 cd $HHH/level_2/comp/$var/src

 cp -f $HHH/level_2/com/comp/norm_pc_devide.f90.com .
 cp -f $HHH/level_2/com/comp/amp_pha.ctl.com .

 sed "s/num_t/$TTT/g"   amp_pha.ctl.com > tmp1
 sed "s/missing/$MMM/g"               tmp1 > amp_pha.ctl

 sed "s#homedir#$HHH#g" norm_pc_devide.f90.com > tmp1
 sed "s/num_t/$TTT/g"                        tmp1 > tmp2
 sed "s/sign1/$SN1/g"                        tmp2 > tmp1
 sed "s/sign2/$SN2/g"                        tmp1 > tmp2
 sed "s/linux_recl/$LNX/g"                   tmp2 > norm_pc_devide.f90

 $FC norm_pc_devide.f90 
 ./a.out
 rm -f a.out

 done
