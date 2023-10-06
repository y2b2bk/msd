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

 for var in olr u850 u200
 do

 export XXX=144
 export YYY=73
 export TTT=2557
 export MMM=-9.99e8
 export PPP=19790101_19851231

# for ctl file
 export BLO=0.0
 export BLA=-90.0
 export DLO=2.5
 export DLA=2.5

 cd $HHH/level_1/$var

 mkdir -p src/zm2
 cd src/zm2

 cp -f $HHH/level_2/com/zm2/zm2.gs.com .

 sed "s#homedir#$HHH#g" zm2.gs.com > tmp1
 sed "s/variable/$var/g"         tmp1 > tmp2
 sed "s/num_t/$TTT/g"            tmp2 > tmp1
 sed "s/num_x/$XXX/g"            tmp1 > tmp2
 sed "s/num_y/$YYY/g"            tmp2 > tmp1
 sed "s/period/$PPP/g"           tmp1 > zm2.gs

grads -lbc << EOF
zm2
EOF


 cd $HHH/level_1/$var/data
 cp -f $HHH/level_2/com/zm2/zm2.ctl.com .

 sed "s/num_x/$XXX/g"    zm2.ctl.com > tmp1
 sed "s/num_y/1/g"                 tmp1 > tmp2
 sed "s/num_t/$TTT/g"              tmp2 > tmp1
 sed "s/beg_lon/$BLO/g"            tmp1 > tmp2
 sed "s/beg_lat/$BLA/g"            tmp2 > tmp1
 sed "s/del_lon/$DLO/g"            tmp1 > tmp2
 sed "s/del_lat/$DLA/g"            tmp2 > tmp1
 sed "s/zm/10S10N/g"               tmp1 > tmp2
 sed "s/missing/$MMM/g"            tmp2 > tmp1
 sed "s/period/$PPP/g"             tmp1 > daily.10S10N.$PPP.ctl

 sed "s/num_x/$XXX/g"    zm2.ctl.com > tmp1
 sed "s/num_y/1/g"                 tmp1 > tmp2
 sed "s/num_t/$TTT/g"              tmp2 > tmp1
 sed "s/beg_lon/$BLO/g"            tmp1 > tmp2
 sed "s/beg_lat/$BLA/g"            tmp2 > tmp1
 sed "s/del_lon/$DLO/g"            tmp1 > tmp2
 sed "s/del_lat/$DLA/g"            tmp2 > tmp1
 sed "s/zm/10S10N/g"               tmp1 > tmp2
 sed "s/missing/$MMM/g"            tmp2 > tmp1
 sed "s/period/$PPP/g"             tmp1 > tmp2
 sed "s/daily/daily.anom/g"        tmp2 > daily.anom.10S10N.$PPP.ctl

# end
 done
