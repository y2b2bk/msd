#!/bin/sh
set -vx

# HHH  : home directory
# MJO  : variable (e.g. OLR, PRCP)
# TVV  : data source
# CLV  : contour levels
# CLO  : colors for shading
# OPT  : option number for writing unit
#( 1: doesn't have order, 2: has order )
# UN1  : unit (e.g. W m)
# OR1  : order (e.g. -2)
# TSEA : title (season)

 source ../../../env.sh

# foreach var ( olr_av trmm gpcp slp_n1 u200_n1 u200_n2 u850_n1 u850_n2 )
 for var in olr_av
 do

# variable
 if [ $var == 'olr_av' ]; then
  export MJO=OLR
  export TVV=AVHRR
 elif [ $var == 'trmm' ]; then
  export MJO=PRCP
  export TVV=TRMM
 elif [ $var == 'gpcp' ]; then
  export MJO=PRCP
  export TVV=GPCP
 elif [ $var == 'slp_n1' ]; then
  export MJO=SLP
  export TVV=NCEP1
 elif [ $var == 'u200_n1' ]; then
  export MJO=U200
  export TVV=NCEP1
 elif [ $var == 'u200_n2' ]; then
  export MJO=U200
  export TVV=NCEP2
 elif [ $var == 'u200_e' ]; then
  export MJO=U200
  export TVV=ERA40
 elif [ $var == 'u850_n1' ]; then
  export MJO=U850
  export TVV=NCEP1
 elif [ $var == 'u850_n2' ]; then
  export MJO=U850
  export TVV=NCEP2
 elif [ $var == 'u850_e' ]; then
  export MJO=U850
  export TVV=ERA40
 fi

 if [ $MJO == 'OLR' ]; then
  export OPT=2
  export CLV='-24 -21 -18 -15 -12 -9 -6 -3 3 6 9 12 15 18 21 24'
  export CLO='33 34 35 36 37 38 39 40 0 41 42 43 44 45 46 47 48'
  export UN1='W m'
  export OR1=-2
 elif [ $MJO == 'PRCP' ]; then
  export OPT=2
  export CLV='-4.0 -3.5 -3.0 -2.5 -2.0 -1.5 -1.0 -0.5 0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0'
  export CLO='48 47 46 45 44 43 42 41 0 40 39 38 37 36 35 34 33'
  export UN1='mm day'
  export OR1=-1
 elif [ $MJO == 'SLP' ]; then
  export OPT=1
  export CLV='-1.2 -1.0 -0.8 -0.6 -0.4 -0.2 0.2 0.4 0.6 0.8 1.0 1.2'
  export CLO='35 36 37 38 39 40 0 41 42 43 44 45 46'
  export UN1=hPa
  export OR1=1
 elif [ $MJO == 'U200' ]; then
  export OPT=2
  export CLV='-8 -7 -6 -5 -4 -3 -2 -1 1 2 3 4 5 6 7 8'
  export CLO='33 34 35 36 37 38 39 40 0 41 42 43 44 45 46 47 48'
  export UN1='m s'
  export OR1=-1
 elif [ $MJO == 'U850' ]; then
  export OPT=2
  export CLV='-3.5 -3 -2.5 -2 -1.5 -1 -0.5 0.5 1 1.5 2 2.5 3 3.5'
  export CLO='34 35 36 37 38 39 40 0 41 42 43 44 45 46 47'
  export UN1='m s'
  export OR1=-1
 fi

 for sea in sum win 
 #for sea in sum 
 do

# season
 if [ $sea == 'sum' ]; then
  export TSEA='May to October'
 elif [ $sea == 'win' ]; then
  export TSEA='November to April'
 fi

# file copy
 cd $HHH/level_2
 mkdir -p fig/comp/2d
 cd fig/comp/2d
 cp -f $HHH/level_2/com/comp/gs_2d.sea.com .

 sed "s#homedir#$HHH#g"                gs_2d.sea.com > tmp2
 sed "s/variable/$var/g"                           tmp2 > tmp1
 sed "s/title_var/$TVV/g"                          tmp1 > tmp2
 sed "s/title_mjo/$MJO/g"                          tmp2 > tmp1
 sed "s/season/$sea/g"                             tmp1 > tmp2
 sed "s/title_sea/$TSEA/g"                         tmp2 > tmp1
 sed "s/option/$OPT/g"                             tmp1 > tmp2
 sed "s/levels/$CLV/g"                             tmp2 > tmp1
 sed "s/colors/$CLO/g"                             tmp1 > tmp2
 sed "s/unit1/$UN1/g"                              tmp2 > tmp1
 sed "s/order1/$OR1/g"                             tmp1 > tmp2
 sed "s/vname/$MJO/g"                              tmp2 > comp_2d.sea.gs

grads -pb << EOF
comp_2d.sea
EOF

# end 
 done
# foreach sea

# end 
 done
# foreach var
