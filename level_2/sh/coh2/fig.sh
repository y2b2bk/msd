#!/bin/sh
set -vx

# HHH  : home directory
# MJO  : variable (e.g. OLR, PRCP)
# OR1  : order (e.g. -1)

 source ../../../env.sh

 for var in u850 u200
 do

 if [ $var == 'u850' ]; then
  export MJO=U850
  export TVV=NCEP1
 fi
 if [ $var == 'u200' ]; then
  export MJO=U200
  export TVV=NCEP1
 fi

 export PPP=19790101_20051231

# file copy
 cd $HHH/level_2
 mkdir -p fig/coh2
 cd fig/coh2
 cp -f $HHH/level_2/com/coh2/exec.com .

 sed "s#homedir#$HHH#g"                           exec.com > tmp2
 sed "s/variable/$var/g"                                 tmp2 > tmp1
 sed "s/title_var/$TVV/g"                                tmp1 > tmp2
 sed "s/title_mjo/$MJO/g"                                tmp2 > tmp1
 sed "s/period/$PPP/g"                                   tmp1 > tmp2
 sed "s/vname/$MJO/g"                                    tmp2 > coh2.exec

grads -lbc << EOF
exec coh2.exec
EOF

# end 
 done
# foreach var
