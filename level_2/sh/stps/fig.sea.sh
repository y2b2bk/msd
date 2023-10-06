#!/bin/sh
set -vx

# HHH  : home directory
# MJO  : variable (e.g. OLR, PRCP)
# CLV  : contour levels
# TVA  : title
# TSE  : title (season)

 source ../../../env.sh

 for var in olr u850 u200
 do

# variable
 if [ $var == 'olr' ]; then
  export MJO=OLR
  export TVA='OLR(AVHRR)'
  export CLV='0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8'
 elif [ $var == 'u850' ]; then
  export MJO=U850
  export TVA='U850(NCEP1)'
  export CLV='0.007 0.014 0.021 0.028 0.035 0.042 0.049 0.056 0.063'
 elif [ $var == 'u200_n1' ]; then
  export MJO=U200
  export TVA='U200(NCEP1)'
  export CLV='0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45'
 fi

 for sea in sum win 
 do

 if [ $sea == 'win' ]; then
  export TSE='Winter (Nov-Apr)'
 elif [ $sea == 'sum' ]; then
  export TSE='Summer (May-Oct)'
 fi 

# file copy
 cd $HHH/level_2
 mkdir -p fig/stps/$sea
 cd fig/stps/$sea
 cp -f $HHH/level_2/com/stps/stps.sea.gs.com .

 sed "s#homedir#$HHH#g"             stps.sea.gs.com > tmp1
 sed "s/variable/$var/g"                          tmp1 > tmp2
 sed "s/season/$sea/g"                            tmp2 > tmp1
 sed "s/title_sea/$TSE/g"                         tmp1 > tmp2
 sed "s/title_var/$TVA/g"                         tmp2 > tmp1
 sed "s/levels/$CLV/g"                            tmp1 > stps.sea.gs

grads -lbc << EOF
stps.sea
EOF

# end
 done
# foreach sea

# end 
 done
# foreach var
