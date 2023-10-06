#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data
# TTT  : number of total time (in day) - total period
# LNX  : whether the machine is linux or not
#  This is for the record length problem.
#  (e.g. 4 : linux machine, 1 : other machine)
# MMM  : missing value
# SN1, SN2 : sign of 1st and 2nd PCs 

 source ../../../env.sh

 for var in ceof 
 do

# export TTT=9862
 export TTT=2557
# export LNX=4
 export MMM=-999.
 export SN1=1
 export SN2=-1
# export FC=gfortran

 cd $HHH/level_2/$var

# source directory
 mkdir -p src/pcl
 cd src/pcl

 cp -f $HHH/level_2/com/ceof/input.nml.com .
 cp -f $HHH/level_2/com/ceof/llreg_2d.f90 .

 sed "s#homedir#$HHH#g"         input.nml.com > tmp1
 sed "s/variable/$var/g"                    tmp1 > tmp2
 sed "s/num_t/$TTT/g"                       tmp2 > tmp1
 sed "s/linux_recl/$LNX/g"                  tmp1 > tmp2
 sed "s/missing/$MMM/g"                     tmp2 > tmp1
 sed "s/sign1/$SN1/g"                       tmp1 > tmp2
 sed "s/sign2/$SN2/g"                       tmp2 > input.nml

 $FC llreg_2d.f90
 ./a.out
 rm -f a.out

#end
 done
