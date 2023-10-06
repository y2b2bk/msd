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
# TTT  : number of total time (in day)
# SEG  : number of days in one segment
# OVL  : overlap days between segments
# LNX  : whether the machine is linux or not
#  This is for the record length problem.
#  (e.g. 4 : linux machine, 1 : other machine)
# PPP  : period of data
# MMM  : missing value

# for ctl file
# BLO  : starting longitude
# BLA  : starting latitude
# DLO  : delta longitude
# DLA  : delta latitude

 source ../../../env.sh

 for var in olr u850 u200
 do

 export XXX=144
 export YYY=73
 export SYY=13
 export JYY=30
# export TTT 9855
 export TTT=2557
 export SEG=96
 export OVL=60
# export LNX 1
 export LNX=4
# export PPP 19790101_20051231
 export PPP=19790101_19851231
# export MMM -999.
 export MMM='-9.99e8'

 export BLO=0.0
 export ILO=2.5
 export BLA=-15.0
 export ILA=2.5

 mkdir -p $HHH/level_2/wk99
 cd $HHH/level_2/wk99
 mkdir -p $var
 cd $var

 mkdir -p data src

 cd data
 cp -f $HHH/level_2/com/wk99/ctl.sym.com .
 cp -f $HHH/level_2/com/wk99/ctl.asy.com .

 sed "s/num_x/$XXX/g"   ctl.sym.com > tmp1
 sed "s/sel_y/$SYY/g"             tmp1 > tmp2
 sed "s/beg_x/$BLO/g"             tmp2 > tmp1
 sed "s/int_x/$ILO/g"             tmp1 > tmp2
 sed "s/beg_y/$BLA/g"             tmp2 > tmp1
 sed "s/int_y/$ILA/g"             tmp1 > tmp2
 sed "s/num_s/$SEG/g"             tmp2 > tmp1
 sed "s/missing/$MMM/g"           tmp1 > tmp2
 sed "s/period/$PPP/g"            tmp2 > sym.ctl

 sed "s/num_x/$XXX/g"   ctl.asy.com > tmp1
 sed "s/sel_y/$SYY/g"             tmp1 > tmp2
 sed "s/beg_x/$BLO/g"             tmp2 > tmp1
 sed "s/int_x/$ILO/g"             tmp1 > tmp2
 sed "s/beg_y/$BLA/g"             tmp2 > tmp1
 sed "s/int_y/$ILA/g"             tmp1 > tmp2
 sed "s/num_s/$SEG/g"             tmp2 > tmp1
 sed "s/missing/$MMM/g"           tmp1 > tmp2
 sed "s/period/$PPP/g"            tmp2 > asy.ctl

 cd ../src
 cp -f $HHH/level_2/com/wk99/seg_part.f90.com .

 sed "s#homedir#$HHH#g" seg_part.f90.com > tmp1
 sed "s/variable/$var/g"             tmp1 > tmp2
 sed "s/num_t/$TTT/g"                tmp2 > tmp1
 sed "s/num_x/$XXX/g"                tmp1 > tmp2
 sed "s/num_y/$YYY/g"                tmp2 > tmp1
 sed "s/sel_y/$SYY/g"                tmp1 > tmp2
 sed "s/jump_y/$JYY/g"               tmp2 > tmp1
 sed "s/num_s/$SEG/g"                tmp1 > tmp2
 sed "s/num_o/$OVL/g"                tmp2 > tmp1
 sed "s/linux_recl/$LNX/g"           tmp1 > tmp2
 sed "s/missing/$MMM/g"              tmp2 > tmp1
 sed "s/period/$PPP/g"               tmp1 > seg_part.f90
 
 $FC seg_part.f90
 ./a.out
 rm -f a.out

# end
 done

