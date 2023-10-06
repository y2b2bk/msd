#!/bin/sh
set -vx

# HHH  : home directory
# ONL  : name of olr data
# MJO  : variable (e.g. OLR, PRCP)
# TVV  : data source
# CLV  : contour levels
# CLO  : colors for shading
# OPT  : option number for writing unit
#( 1: doesn't have order, 2: has order )
# UN1  : unit (e.g. W m)
# OR1  : order (e.g. -2)
# ZTO  : number of top level in pressure/height
# ( figure will be drawn from z=1 to z=ZTO )
# TSEA : title (season)

 source ../../../env.sh

 export ONM=olr_av

 for var in u3d_n1 t3d_n1 q3d_n1 om3d_n1 
 do

# variable

 if [ $var == 'u3d_n1' ]; then
  export MJO=U
  export TVV=NCEP1
 fi
 if [ $var == 't3d_n1' ]; then
  export MJO=T
  export TVV=NCEP1
 fi
 if [ $var == 'q3d_n1' ]; then
  export MJO=Q
  export TVV=NCEP1
 fi
 if [ $var == 'om3d_n1' ]; then
  export MJO=OM
  export TVV=NCEP1
 fi

 if [ $MJO == 'U' ]; then
  export MJO='Zonal wind'
  export ZTO=12
  export OPT=1
  export CLV='-5 -4 -3 -2 -1 1 2 3 4 5'
  export CLO='36 37 38 39 40 0 41 42 43 44 45'
  export UN1=ms
  export OR1=-1
 fi
 if [ $var == 'T' ]; then
  export MJO='Temperature'
  export ZTO=12
  export OPT=2
  export CLV='-0.8 -0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8'
  export CLO='33 34 35 36 37 38 39 40 0 41 42 43 44 45 46 47 48'
  export UN1=K
  export OR1=1
 fi
 if [ $var == 'Q' ]; then
  export MJO='Specific humidity'
  export ZTO=12
  export OPT=3
  export CLV='-0.5 -0.4 -0.3 -0.2 -0.1 0.1 0.2 0.3 0.4 0.5'
  export CLO='45 44 43 42 41 0 40 39 38 37 36'
  export UN1=kgkg
  export OR1=-1
 fi
 if [ $var == 'OM' ]; then
  export MJO='Pressure Velocity'
  export ZTO=12
  export OPT=4
  export CLV='-0.016 -0.014 -0.012 -0.010 -0.008 -0.006 -0.004 -0.002 0.002 0.004 0.006 0.008 0.010 0.012 0.014 0.016'
  export CLO='33 34 35 36 37 38 39 40 0 41 42 43 44 45 46 47 48'
  export UN1=Pas
  export OR1=-1
 fi

 for sea in sum win 
 do

# season
 if [ $sea == 'sum' ]; then
  export TSEA='May to October'
 elif [ $sea == 'win' ]; then
  export TSEA='November to April'
 fi

# file copy
 cd $HHH/level_2
 mkdir -p fig/comp/3d
 cd fig/comp/3d
 cp -f $HHH/level_2/sample/comp/gs_3d.sea.sample .

 sed "s#homedir#$HHH#g"                gs_3d.sea.sample > tmp2
 sed "s/variable/$var/g"                           tmp2 > tmp1
 sed "s/title_var/$TVV/g"                          tmp1 > tmp2
 sed "s/title_mjo/$MJO/g"                          tmp2 > tmp1
 sed "s/season/$sea/g"                             tmp1 > tmp2
 sed "s/title_sea/$TSEA/g"                         tmp2 > tmp1
 sed "s/ztop/$ZTO/g"                               tmp1 > tmp2
 sed "s/olr_name/$ONM/g"                           tmp2 > tmp1
 sed "s/option/$OPT/g"                             tmp1 > tmp2
 sed "s/levels/$CLV/g"                             tmp2 > tmp1
 sed "s/colors/$CLO/g"                             tmp1 > tmp2
 sed "s/unit1/$UN1/g"                              tmp2 > tmp1
 sed "s/order1/$OR1/g"                             tmp1 > tmp2
 sed "s/vname/$var/g"                              tmp2 > comp_3d.sea.gs

grads -lbc << EOF
comp_3d.sea
EOF

# end 
 done
# foreach sea

# end 
 done
# foreach var
