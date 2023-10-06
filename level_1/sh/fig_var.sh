#!/bin/sh
set -vx

# HHH  : home directory
# MJO  : variable (e.g. OLR, PRCP)
# LVT  : contour levels (total variance)
# LVF  : contour levels (filtered variance)
# UN1  : unit (e.g. W m)
# OR1  : order (e.g. -1)

 source ../../env.sh

 for var in olr_av u850_n1 u200_n1
 do

# variable
 if [ $var == 'olr' ]; then
  export MJO=OLR
  export TVA=AVHRR
  export LVT='400 600 800 1000 1200 1400 1600 1800 2000'
  export LVF='200 250 300 350 400 450 500 550 600'
  export UN1='W m'
  export OR1='2'
 elif [ $var == 'u850' ]; then
  export MJO=U850
  export TVA=NCEP1
  export LVT='4 8 12 16 20 24 28 32 38'
  export LVF='3 4 5 6 7 8 9 10 11'
  export UN1='m s'
  export OR1='1'
 elif [ $var == 'u200' ]; then
  export MJO=U200
  export TVA=NCEP1
  export LVT='40 60 80 100 120 140 160 180 200'
  export LVF='10 15 20 25 30 35 40 45 50'
  export UN1='m s'
  export OR1='1'
 fi

# file copy
 cd $HHH/level_1
 mkdir -p fig/var/$var
 cd fig/var/$var
 cp -f $HHH/level_1/com/var/var.gs.com .

 for sea in all sum win 
 do

 if [ $sea == 'all' ]; then
 export TSE='All season' 
 elif [ $sea == 'sum' ]; then
 export TSE='Summer(May-Oct)'
 elif [ $sea == 'win' ]; then
 export TSE='Winter(Nov-Apr)'
 fi

 sed "s#homedir#$HHH#g"                   var.gs.com > tmp1
 sed "s/variable/$var/g"                           tmp1 > tmp2
 sed "s/season/$sea/g"                             tmp2 > tmp1
 sed "s/title_sea/$TSE/g"                          tmp1 > tmp2
 sed "s/title_var/$TVA/g"                          tmp2 > tmp1
 sed "s/title_mjo/$MJO/g"                          tmp1 > tmp2
 sed "s/levels_tot/$LVT/g"                         tmp2 > tmp1
 sed "s/levels_fil/$LVF/g"                         tmp1 > tmp2
 sed "s/unit1/$UN1/g"                              tmp2 > tmp1
 sed "s/order1/$OR1/g"                             tmp1 > var.gs

grads -pb << EOF
var
EOF
 
# end
 done
# foreach season

# end 
 done
# foreach var
