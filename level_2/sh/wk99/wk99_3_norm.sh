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
# LLL  : true if olr (to remove aliases in satellite data)

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

 export LLL=false

 if [ $var == 'olr_av' ]; then
 export LLL=true
 fi

 cd $HHH/level_2/wk99
 mkdir -p $var
 cd $var

 mkdir -p power

 cd power
 cp -f $HHH/level_2/com/wk99/ctl.norm.sym.com .
 cp -f $HHH/level_2/com/wk99/ctl.norm.asy.com .
 cp -f $HHH/level_2/com/wk99/ctl.back.com .

 sed "s/ctl_x/$CXX/g"   ctl.norm.sym.com > tmp1
 sed "s/cbg_x/$CBX/g"                  tmp1 > tmp2
 sed "s/missing/$MMM/g"                tmp2 > norm.sym.ctl

 sed "s/ctl_x/$CXX/g"   ctl.norm.asy.com > tmp1
 sed "s/cbg_x/$CBX/g"                  tmp1 > tmp2
 sed "s/missing/$MMM/g"                tmp2 > norm.asy.ctl

 sed "s/ctl_x/$CXX/g"       ctl.back.com > tmp1
 sed "s/cbg_x/$CBX/g"                  tmp1 > tmp2
 sed "s/missing/$MMM/g"                tmp2 > back.ctl

 cd ../src
 cp -f $HHH/level_2/com/wk99/log_smoo.f90.com .

 sed "s#homedir#$HHH#g"  log_smoo.f90.com > tmp1
 sed "s/variable/$var/g"              tmp1 > tmp2
 sed "s/num_x/$XXX/g"                 tmp2 > tmp1
 sed "s/missing/$MMM/g"               tmp1 > tmp2
 sed "s/torf/$LLL/g"                  tmp2 > tmp1
 sed "s/linux_recl/$LNX/g"            tmp1 > tmp2
 sed "s/num_s/$SEG/g"                 tmp2 > log_smoo.f90

 $FC log_smoo.f90
 ./a.out
 rm -f a.out

 done
