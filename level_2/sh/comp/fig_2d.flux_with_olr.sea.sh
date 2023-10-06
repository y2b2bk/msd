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
# TSEA : title (season)

 source ../../../env.sh

 export ONM=olr_av

 for var in sst_tmi sst_oi evap_e evap_n1 evap_oa ssr_is ssr_ge 
 do

# variable

 if [ $var == 'sst_tmi' ]; then
  export MJO=SST
  export TVV=TMI
 fi
 if [ $var == 'sst_oi' ]; then
  export MJO=SST
  export TVV=OISST
 fi
 if [ $var == 'evap_e' ]; then
  export MJO=EVAP
  export TVV=ERA40
 fi
 if [ $var == 'evap_n1' ]; then
  export MJO=EVAP
  export TVV=NCEP1
 fi
 if [ $var == 'evap_oa' ]; then
  export MJO=EVAP
  export TVV=OAflux
 fi
 if [ $var == 'ssr_is' ]; then
  export MJO=NSSR
  export TVV=ISCCP-FD
 fi
 if [ $var == 'ssr_ge' ]; then
  export MJO=NSSR
  export TVV=GEWEX-SRB
 fi

 if [ $MJO == 'SST' ]; then
  export OPT=1
  export LLL='-0.4 -0.35 -0.3 -0.25 -0.2 -0.15 -0.1 -0.05 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4'
  export CCC='33 34 35 36 37 38 39 40 0 41 42 43 44 45 46 47 48'
  export UUU=K
  export ODR=1
  export FAC=1
 elif [ $var == 'EVAP' ]; then
  export OPT=2
  export LLL='-24 -21 -18 -15 -12 -9 -6 -3 3 6 9 12 15 18 21 24'
  export CCC='33 34 35 36 37 38 39 40 0 41 42 43 44 45 46 47 48'
  export UUU='W m'
  export ODR=-2
  export FAC=1
 elif [ $var == 'NSSR' ]; then
  export OPT=2
  export LLL='-32 -28 -24 -20 -16 -12 -8 -4 4 8 12 16 20 24 28 32'
  export CCC='33 34 35 36 37 38 39 40 0 41 42 43 44 45 46 47 48'
  export UUU='W m'
  export ODR=-2
  export FAC=1
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
 mkdir -p fig/comp/2d_olr
 cd fig/comp/2d_olr
 cp -f $HHH/level_2/sample/comp/gs_2d.sea.with_olr.sample .

 sed "s#homedir#$HHH#g"          gs_2d.sea.with_olr.sample > tmp2
 sed "s/variable/$var/g"                              tmp2 > tmp1
 sed "s/title_var/$TVV/g"                             tmp1 > tmp2
 sed "s/title_mjo/$MJO/g"                             tmp2 > tmp1
 sed "s/season/$sea/g"                                tmp1 > tmp2
 sed "s/title_sea/$TSEA/g"                            tmp2 > tmp1
 sed "s/option/$OPT/g"                                tmp1 > tmp2
 sed "s/levels/$LLL/g"                                tmp2 > tmp1
 sed "s/colors/$CCC/g"                                tmp1 > tmp2
 sed "s/unit1/$UUU/g"                                 tmp2 > tmp1
 sed "s/order1/$ODR/g"                                tmp1 > tmp2
 sed "s/olr_name/$ONM/g"                              tmp2 > tmp1
 sed "s/factor/$FAC/g"                                tmp1 > tmp2
 sed "s/vname/$MJO/g"                                 tmp2 > comp_2d.flux_with_olr.sea.sh

grads -pbc << EOF
comp_2d.flux_with_olr.sea
EOF

# end 
 done
# foreach sea

# end 
 done
# foreach var
