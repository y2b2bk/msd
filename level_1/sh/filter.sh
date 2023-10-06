#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data
# XXX  : number of grid in longitude
# YYY  : number of grid in latitude
# TTT  : number of total time (in day)
# MMM  : missing value
# PPP  : period of data

 source ../../env.sh

 for var in olr_av u850_n1 u200_n1
 do

# export XXX=144
# export YYY=73
 export TTT=2557
 export MMM=-9.99e8
 export PPP=19790101_19851231

 cd $HHH/level_1/$var

 mkdir -p src/filter
 cd src/filter

 cp -f $HHH/level_1/com/filter/filter.f90 .
 cp -f $HHH/level_1/com/filter/coef.dat .
 cp -f $HHH/level_1/com/filter/filter.nml.com .

 sed "s#homedir#$HHH#g"  filter.nml.com > tmp1
 sed "s/variable/$var/g"              tmp1 > tmp2
 sed "s/num_x/$XXX/g"                 tmp2 > tmp1
 sed "s/num_y/$YYY/g"                 tmp1 > tmp2
 sed "s/num_t/$TTT/g"                 tmp2 > tmp1
 sed "s/dmiss/$MMM/g"                 tmp1 > tmp2
 sed "s/period/$PPP/g"                tmp2 > filter.nml

 $FC filter.f90 -o filter
 ./filter < filter.nml 

 cd $HHH/level_1/$var/data

 sed "s/daily/daily.filt.20-100.lanz.100/g" daily.$PPP.ctl > daily.filt.20-100.lanz.100.$PPP.ctl
 
 done
