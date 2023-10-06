#!/bin/sh
set -vx

# HHH  : home directory
# ONL  : name of olr data
# MJO  : variable (e.g. OLR, PRCP)
# TVV  : data source
# CLV  : contour levels
# CLO  : colors for shading
# OPT  : option number for writing unit
# ( 1: doesn't have order, 2: has order )
# UN1  : unit (e.g. W m)
# OR1  : order (e.g. -2)
# AHH  : arrow head size
# ASS  : arrow scale
# TSEA : title (season)

 source ../../../env.sh

 export ONM=olr_av

# for var in 850 200 sfc
 for var in 850 
 do

# for data in n1 n2 e
 for data in n1 
 do

 if [ $data == 'n1' ]; then
   export TVV=NCEP1
 elif [ $data == 'n2' ]; then
   export TVV=NCEP2
 elif [ $data == 'e' ]; then
   export TVV=ERA40
 fi

# variable
 if [ $var == '850' ]; then
  export mjo=850hPa
  export AHH=0.03
  export ASS=3
 elif [ $var == '200' ]; then
  export mjo=200hPa
  export AHH=0.03
  export ASS=7
 elif [ $var == 'sfc' ]; then
  export mjo=Surface
  export AHH=0.03
  export ASS=3
 fi

 export UNM=U${var}_${data}
 export VNM=V${var}_${data}

 echo $UNM
 echo $VNM
 exit

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
 mkdir -p fig/comp/wind
 cd fig/comp/wind
 cp -f $HHH/level_2/com/comp/gs_wind.sea.com .

 sed "s#homedir#$HHH#g"                    gs_wind.sea.com > tmp2
 sed "s/variable/$var/g"                                 tmp2 > tmp1
 sed "s/title_var/$TVV/g"                                tmp1 > tmp2
 sed "s/title_mjo/$mjo/g"                                tmp2 > tmp1
 sed "s/season/$sea/g"                                   tmp1 > tmp2
 sed "s/title_sea/$TSEA/g"                               tmp2 > tmp1
 sed "s/ahhh/$AHH/g"                                     tmp1 > tmp2
 sed "s/asss/$ASS/g"                                     tmp2 > tmp1
 sed "s/lll/$var/g"                                      tmp1 > tmp2
 sed "s/olr_name/$ONM/g"                                 tmp2 > tmp1
 sed "s/u_name/$UNM/g"                                   tmp1 > tmp2
 sed "s/v_name/$VNM/g"                                   tmp2 > tmp1
 sed "s/order1/-1/g"                                     tmp1 > comp_wind.sea.gs

grads -pbc << EOF
comp_wind.sea
EOF

# end
 done
# foreach sea

# end
 done
# foreach data

# end 
 done
# foreach var

