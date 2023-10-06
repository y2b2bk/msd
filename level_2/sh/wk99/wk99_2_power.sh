#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data
# XXX  : number of grid in longitude
# YYY  : number of grid in latitude
# SXX  : selected number of grid in longitude
# SYY  : selected number of grid in latitude
# JYY  : ignored number of grid in latitude
#  y-grid in result file start from JYY+1
# TSS  : number of segments
#  results from wk99_1_seg.sh
# SEG  : number of days in one segment
# OVL  : overlap days between segments
# LNX  : whether the machine is linux or not
#  This is for the record length problem.
#  (e.g. 4 : linux machine, 1 : other machine)
# PPP  : period of data
# MMM  : missing value

# for ctl file
# CXX  : number of x in power spectra
# CBX  : start longitude (no meaning, just for ctl file)

 source ../../../env.sh

 for var in olr u850 u200
 do

 export XXX=144
 export YYY=73
 export SYY=13
 export JYY=30
# export TSS number of segments
# export TSS 272
 export TSS=69
 export SEG=96
 export OVL=60
# export LNX 1
 export LNX=4
# export PPP 19790101_20051231
 export PPP=19790101_19851231
# export MMM -999.
 export MMM='-9.99e8'

 export CXX=145
 export CBX=-72.0

 cd $HHH/level_2/wk99
 mkdir -p $var
 cd $var

 mkdir -p power

 cd power
 cp -f $HHH/level_2/com/wk99/ctl.power.sym.com .
 cp -f $HHH/level_2/com/wk99/ctl.power.asy.com .

 sed "s/ctl_x/$CXX/g"   ctl.power.sym.com > tmp1
 sed "s/cbg_x/$CBX/g"                   tmp1 > tmp2
 sed "s/missing/$MMM/g"                 tmp2 > sym.ctl

 sed "s/ctl_x/$CXX/g"   ctl.power.asy.com > tmp1
 sed "s/cbg_x/$CBX/g"                   tmp1 > tmp2
 sed "s/missing/$MMM/g"                 tmp2 > asy.ctl

 cd ../src
 cp -f $HHH/level_2/com/wk99/power.sym.f90.com .
 cp -f $HHH/level_2/com/wk99/power.asy.f90.com .
 cp -f $HHH/level_2/com/wk99/makefile .
 cp -f $HHH/tools/fftpack/libfftpack.a .


 sed "s#homedir#$HHH#g" power.sym.f90.com > tmp1
 sed "s/variable/$var/g"              tmp1 > tmp2
 sed "s/tot_s/$TSS/g"                 tmp2 > tmp1
 sed "s/num_x/$XXX/g"                 tmp1 > tmp2
 sed "s/sel_y/$SYY/g"                 tmp2 > tmp1
 sed "s/linux_recl/$LNX/g"            tmp1 > tmp2
 sed "s/num_s/$SEG/g"                 tmp2 > spctime.f90

 echo 'symmetric'
 pwd
 make
 ./spctime 
 cp spctime.f90 spctime_sym.f90
 rm -f spctime.f90 spctime

 sed "s#homedir#$HHH#g" power.asy.f90.com > tmp1
 sed "s/variable/$var/g"              tmp1 > tmp2
 sed "s/tot_s/$TSS/g"                 tmp2 > tmp1
 sed "s/num_x/$XXX/g"                 tmp1 > tmp2
 sed "s/sel_y/$SYY/g"                 tmp2 > tmp1
 sed "s/linux_recl/$LNX/g"            tmp1 > tmp2
 sed "s/num_s/$SEG/g"                 tmp2 > spctime.f90

 echo 'asymmetric'
 pwd
 make
 ./spctime 
 cp spctime.f90 spctime_asy.f90
 rm -f spctime.f90 spctime

 done
