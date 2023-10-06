#!/bin/sh
set -vx

# HHH  : home directory
# MJO  : variable (e.g. OLR, PRCP)
# OR1  : order (e.g. -1)

 source ../../../env.sh

 for var in olr u850 u200
 do

 if [ $var == 'olr' ]; then
 export MJO=OLR
 export TVV=AVHRR
 fi
 if [ $var == 'u850' ]; then
  export MJO=U850
  export TVV=NCEP1
 fi
 if [ $var == 'u200' ]; then
  export MJO=U200
  export TVV=NCEP1
 fi

 export PPP=19790101_19851231

# file copy
 cd $HHH/level_2
 mkdir -p fig/wk99
 cd fig/wk99
 cp -f $HHH/level_2/com/wk99/exec.com .

 sed "s#homedir#$HHH#g"                           exec.com > tmp1
 sed "s/variable/$var/g"                                 tmp1 > tmp2
 sed "s/title_var/$TVV/g"                                tmp2 > tmp1
 sed "s/title_mjo/$MJO/g"                                tmp1 > tmp2
 sed "s/period/$PPP/g"                                   tmp2 > wk99.exec

grads -lbc << EOF
exec wk99.exec
EOF

# end 
 done
# foreach var
