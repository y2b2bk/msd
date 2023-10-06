#!/bin/sh
set -vx

# HHH  : home directory
# MJO  : variable (e.g. OLR, PRCP)
# TVA  : title
# TSE  : title (season)

 source ../../env.sh

 for var in olr_av u850_n1 u200_n1
 do

# variable
 if [ $var == 'olr_av' ]; then
  export mjo=OLR
  export TVA='OLR(AVHRR)'
 elif [ $var == 'u850_n1' ]; then
  export mjo=U850
  export TVA='U850(NCEP1)'
 elif [ $var == 'u200_n1' ]; then
  export mjo=U200
  export TVA='U200(NCEP1)'
 fi

# file copy
 cd $HHH/level_1
 mkdir -p fig/lgc/$var

 cd fig/lgc/$var
 cp -f $HHH/level_1/com/lgc/lgc.east.gs.com .
 cp -f $HHH/level_1/com/lgc/lgc.north.gs.com .

 for exp in east.win east.sum north.io north.wp
 do

 if [ $exp == 'east.win' ]; then
  export TSE='Winter (Nov-Apr)'
 else 
  export TSE='Summer (May-Oct)'
 fi

 if [ $exp == 'east.win' ] || [ $exp == 'east.sum' ]; then
 sed "s#homedir#$HHH#g"             lgc.east.gs.com > tmp1
 elif [ $exp == 'north.io' ] || [ $exp == 'north.wp' ]; then
 sed "s#homedir#$HHH#g"            lgc.north.gs.com > tmp1
 fi

 sed "s/variable/$var/g"                          tmp1 > tmp2
 sed "s/experiment/$exp/g"                        tmp2 > tmp1
 sed "s/title_sea/$TSE/g"                         tmp1 > tmp2
 sed "s/title_var/$TVA/g"                         tmp2 > lgc.gs

grads -lb << EOF
lgc
EOF
 
 done
# exp

 done
# var

