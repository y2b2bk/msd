#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data
# XXX  : number of grid in longitude
# YYY  : number of grid in latitude
# SXX  : number of grid in longitude (5x5)
# SYY  : number of grid in latitude (5x5)
# TTT  : number of total time (in day)
# BLA  : starting latitude (e.g. -90.0 = from South Pole)
# SLA  : starting latitude (5x5)
# LNX  : whether the machine is linux or not
#  This is for the record length problem.
#  (e.g. 4 : linux machine, 1 : other machine)
# MMM  : missing value
# PPP  : period of data

 source ../../env.sh

 for var in olr_av u850_n1 u200_n1
 do

# export XXX=144
# export YYY=73
 export SXX=72
 export SYY=37
# export TTT=2557
 export BLA=-90.0
 export SLA=-90.0
# export LNX=4
 export MMM=-9.99e8
 export PPP=19790101_19851231

 cd $HHH/level_1/$var
 mkdir -p src/5x5
 cd src/5x5

 cp -f $HHH/level_1/com/5x5/intp.fil.f90.com .
 cp -f $HHH/level_1/com/5x5/intp.ano.f90.com .
 cp -f $HHH/level_1/com/5x5/intp_with.f90 .
# ls ./

# anomaly data
 sed "s#homedir#$HHH#g"  intp.ano.f90.com > tmp1
 sed "s/variable/$var/g"                tmp1 > tmp2
 sed "s/num_t/$TTT/g"                   tmp2 > tmp1
 sed "s/num_x/$XXX/g"                   tmp1 > tmp2
 sed "s/num_y/$YYY/g"                   tmp2 > tmp1
 sed "s/sel_x/$SXX/g"                   tmp1 > tmp2
 sed "s/sel_y/$SYY/g"                   tmp2 > tmp1
 sed "s/beg_lat/$BLA/g"                 tmp1 > tmp2
 sed "s/sel_lat/$SLA/g"                 tmp2 > tmp1
 sed "s/linux_recl/$LNX/g"              tmp1 > tmp2
 sed "s/missing/$MMM/g"                 tmp2 > tmp1
 sed "s/period/$PPP/g"                  tmp1 > intp.f90

 cp intp.f90 intpa.f90
 $FC intp.f90 intp_with.f90
 ./a.out
 rm -f a.out

# filtered data
 sed "s#homedir#$HHH#g"  intp.fil.f90.com > tmp1
 sed "s/variable/$var/g"                tmp1 > tmp2
 sed "s/num_t/$TTT/g"                   tmp2 > tmp1
 sed "s/num_x/$XXX/g"                   tmp1 > tmp2
 sed "s/num_y/$YYY/g"                   tmp2 > tmp1
 sed "s/sel_x/$SXX/g"                   tmp1 > tmp2
 sed "s/sel_y/$SYY/g"                   tmp2 > tmp1
 sed "s/beg_lat/$BLA/g"                 tmp1 > tmp2
 sed "s/sel_lat/$SLA/g"                 tmp2 > tmp1
 sed "s/linux_recl/$LNX/g"              tmp1 > tmp2
 sed "s/missing/$MMM/g"                 tmp2 > tmp1
 sed "s/period/$PPP/g"                  tmp1 > intp.f90

 $FC intp.f90 intp_with.f90
 ./a.out
 rm -f a.out

 cd $HHH/level_1/$var/data

 cp -f $HHH/level_1/com/5x5/ano.ctl.com .
 cp -f $HHH/level_1/com/5x5/fil.ctl.com .

 sed "s/num_t/$TTT/g" ano.ctl.com > tmp1
 sed "s/sel_x/$SXX/g"           tmp1 > tmp2
 sed "s/sel_y/$SYY/g"           tmp2 > tmp1
 sed "s/sel_lat/$SLA/g"         tmp1 > tmp2
 sed "s/missing/$MMM/g"         tmp2 > tmp1
 sed "s/period/$PPP/g"          tmp1 > daily.5x5.anom.$PPP.ctl

 sed "s/num_t/$TTT/g" fil.ctl.com > tmp1
 sed "s/sel_x/$SXX/g"           tmp1 > tmp2
 sed "s/sel_y/$SYY/g"           tmp2 > tmp1
 sed "s/sel_lat/$SLA/g"         tmp1 > tmp2
 sed "s/missing/$MMM/g"         tmp2 > tmp1
 sed "s/period/$PPP/g"          tmp1 > daily.5x5.filt.20-100.lanz.100.$PPP.ctl

 #end
 done
