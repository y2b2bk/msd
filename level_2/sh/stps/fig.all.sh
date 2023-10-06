#!/bin/sh

# HHH  : home directory
# MJO  : variable (e.g. OLR, PRCP)
# CLV  : contour levels
# TVA  : title

 source ../../../env.sh

 for var in olr u850 u200
 do

# variable
 if [ $var == 'olr' ]; then
  export MJO=OLR
  export TVA='OLR(AVHRR)'
  export CLV='0.1 0.2 0.4 0.8 1.6 3.2 6.4 12.8 25.6'
 elif [ $var == 'u850' ]; then
  export MJO=U850
  export TVA='U850(NCEP1)'
  export CLV='0.005 0.01 0.02 0.04 0.08 0.16 0.32 0.64 1.28'
 elif [ $var == 'u200_n1' ]; then
  export MJO=U200
  export TVA='U200(NCEP1)'
  export CLV='0.025 0.05 0.1 0.2 0.4 0.8 1.6 3.2 6.4'
 fi

# file copy
 cd $HHH/level_2
 mkdir -p fig/stps/all
 cd fig/stps/all
 cp -f $HHH/level_2/com/stps/stps.all.gs.com .

 sed "s#homedir#$HHH#g"               stps.all.gs.com > tmp1
 sed "s/variable/$var/g"                            tmp1 > tmp2
 sed "s/title_var/$TVA/g"                           tmp2 > tmp1
 sed "s/levels/$CLV/g"                              tmp1 > stps.all.gs

grads -lbc << EOF
stps.all
EOF

# end 
 done
# foreach var

