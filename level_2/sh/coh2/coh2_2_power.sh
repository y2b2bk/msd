#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data
# XXX  : number of grid in longitude
# YYY  : number of grid in latitude
# SYY  : selected number of grid in latitude
# JYY  : ignored number of grid in latitude
#  y-grid in result file start from JYY+1
# TSS  : number of segments
#  results from coh2_1_seg.sh
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

 export ONM=olr

 for var in olr u850 u200
 do

 export XXX=144
 export YYY=73
 export SYY=13
 export JYY=30
 export LNX=4
# export TSS number of segments
# export TSS 192
 export TSS=47
 export SEG=256
 export OVL=206
# export MMM -999.
 export MMM='-9.99e8'
# export PPP 19790101_20051231
 export PPP=19790101_19851231

 export CXX=145
 export CBX=-72

 mkdir -p $HHH/level_2/coh2/$var
 cd $HHH/level_2/coh2/$var

 mkdir -p power

 cd power
 cp -f $HHH/level_2/com/coh2/ctl.power.sym.com .
 cp -f $HHH/level_2/com/coh2/ctl.power.asy.com .
 cp -f $HHH/level_2/com/coh2/ctl.coh2.sym.com .
 cp -f $HHH/level_2/com/coh2/ctl.coh2.asy.com .

 sed "s/ctl_x/$CXX/g"   ctl.power.sym.com > tmp1
 sed "s/cbg_x/$CBX/g"                   tmp1 > tmp2
 sed "s/missing/$MMM/g"                 tmp2 > sym.power.ctl

 sed "s/ctl_x/$CXX/g"   ctl.power.asy.com > tmp1
 sed "s/cbg_x/$CBX/g"                   tmp1 > tmp2
 sed "s/missing/$MMM/g"                 tmp2 > asy.power.ctl

 sed "s/ctl_x/$CXX/g"    ctl.coh2.sym.com > tmp1
 sed "s/cbg_x/$CBX/g"                   tmp1 > tmp2
 sed "s/missing/$MMM/g"                 tmp2 > sym.coh2.ctl

 sed "s/ctl_x/$CXX/g"    ctl.coh2.asy.com > tmp1
 sed "s/cbg_x/$CBX/g"                   tmp1 > tmp2
 sed "s/missing/$MMM/g"                 tmp2 > asy.coh2.ctl

 cd ../src
 cp -f $HHH/level_2/com/coh2/power.f90.com .
 cp -f $HHH/level_2/com/coh2/makefile .
 cp -f $HHH/tools/fftpack/libfftpack.a .

 sed "s#homedir#$HHH#g"  power.f90.com > tmp1
 sed "s/olr_name/$ONM/g"           tmp1 > tmp2
 sed "s/variable/$var/g"           tmp2 > tmp1
 sed "s/tot_s/$TSS/g"              tmp1 > tmp2
 sed "s/num_x/$XXX/g"              tmp2 > tmp1
 sed "s/sel_y/$SYY/g"              tmp1 > tmp2
 sed "s/num_s/$SEG/g"              tmp2 > tmp1
 sed "s/recl_linux/$LNX/g"         tmp1 > spctime.f90

 make
 ./spctime 
 rm -f spctime.f90 spctime

 done
