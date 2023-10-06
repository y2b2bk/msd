#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data
# XXX  : number of grid in longitude
# YYY  : number of grid in latitude
# TTT  : number of total time (in day)
# PPP  : period of data

# for ctl file
# BLO  : starting longitude
# BLA  : starting latitude
# DLO  : delta longitude
# DLA  : delta latitude

 source ../../env.sh

 for var in olr_av u850_n1 u200_n1
 do

# export XXX=144
# export YYY=73
# export TTT=2557
 export MMM=-9.99e8
 export PPP=19790101_19851231

# for ctl file
 export BLO=0.0
 export BLA=-90.0
 export DLO=2.5
 export DLA=2.5

 cd $HHH/level_1/$var

 mkdir -p src/zm
 cd src/zm

 cp -f $HHH/level_1/com/zm/zm.gs.com .

 sed "s#homedir#$HHH#g"  zm.gs.com > tmp1
 sed "s/variable/$var/g"         tmp1 > tmp2
 sed "s/num_t/$TTT/g"            tmp2 > tmp1
 sed "s/num_x/$XXX/g"            tmp1 > tmp2
 sed "s/num_y/$YYY/g"            tmp2 > tmp1
 sed "s/period/$PPP/g"           tmp1 > zm.gs

grads -lbc << EOF
zm
EOF


 cd $HHH/level_1/$var/data
 cp -f $HHH/level_1/com/zm/zm.ctl.com .

 sed "s/num_x/$XXX/g"     zm.ctl.com > tmp1
 sed "s/num_y/1/g"                 tmp1 > tmp2
 sed "s/num_t/$TTT/g"              tmp2 > tmp1
 sed "s/beg_lon/$BLO/g"            tmp1 > tmp2
 sed "s/beg_lat/$BLA/g"            tmp2 > tmp1
 sed "s/del_lon/$DLO/g"            tmp1 > tmp2
 sed "s/del_lat/$DLA/g"            tmp2 > tmp1
 sed "s/zm/10S10N/g"               tmp1 > tmp2
 sed "s/missing/$MMM/g"            tmp2 > tmp1
 sed "s/period/$PPP/g"             tmp1 > daily.filt.20-100.lanz.100.10S10N.$PPP.ctl

 sed "s/num_x/1/g"        zm.ctl.com > tmp1
 sed "s/num_y/$YYY/g"              tmp1 > tmp2
 sed "s/num_t/$TTT/g"              tmp2 > tmp1
 sed "s/beg_lon/$BLO/g"            tmp1 > tmp2
 sed "s/beg_lat/$BLA/g"            tmp2 > tmp1
 sed "s/del_lon/$DLO/g"            tmp1 > tmp2
 sed "s/del_lat/$DLA/g"            tmp2 > tmp1
 sed "s/zm/80E100E/g"              tmp1 > tmp2
 sed "s/missing/$MMM/g"            tmp2 > tmp1
 sed "s/period/$PPP/g"             tmp1 > daily.filt.20-100.lanz.100.80E100E.$PPP.ctl

 sed "s/num_x/1/g"        zm.ctl.com > tmp1
 sed "s/num_y/$YYY/g"              tmp1 > tmp2
 sed "s/num_t/$TTT/g"              tmp2 > tmp1
 sed "s/beg_lon/$BLO/g"            tmp1 > tmp2
 sed "s/beg_lat/$BLA/g"            tmp2 > tmp1
 sed "s/del_lon/$DLO/g"            tmp1 > tmp2
 sed "s/del_lat/$DLA/g"            tmp2 > tmp1
 sed "s/zm/115E135E/g"             tmp1 > tmp2
 sed "s/missing/$MMM/g"            tmp2 > tmp1
 sed "s/period/$PPP/g"             tmp1 > daily.filt.20-100.lanz.100.115E135E.$PPP.ctl

# end
done
