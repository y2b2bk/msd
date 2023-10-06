#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data
# TTT  : number of total time (in day)
# MMM  : missing value
# PPP  : period of data

# region for averaging
# BLO  : starting longitude (e.g. 120, 240)
# BLA  : starting latitude (e.g. -5, 5)
# ELO  : ending longitude
# ELA  : ending latitude

 source ../../env.sh

 for var in olr_av u850_n1 u200_n1
 do

# export TTT=2557
 export MMM=-9.99e8
 export PPP=19790101_19851231

 if [ $var == 'olr_av' ]; then
   export MJO=OLR
 elif [ $var == 'u850_n1' ]; then
   export MJO=U850
 elif [ $var == 'u200_n1' ]; then
   export MJO=U200
 fi

 cd $HHH/level_1/$var

 mkdir -p src/aave
 cd src/aave

 cp -f $HHH/level_1/com/aave/aave.gs.com .
 cp -f $HHH/level_1/com/aave/aave.ctl.com .

 for sea in win sum 
 do

 if [ $MJO == 'OLR' ]; then

  if [ $sea == 'win' ]; then

   for reg in IO WP MC 
   do

    if [ $reg == 'IO' ]; then
      export BLO=75 
      export ELO=100
      export BLA=-10
      export ELA=5
    elif [ $reg == 'WP' ]; then
      export BLO=160
      export ELO=185
      export BLA=-20
      export ELA=-5
    elif [ $reg == 'MC' ]; then
      export BLO=115
      export ELO=145
      export BLA=-17.5
      export ELA=-2.5
    fi
# Area averaging!
 sed "s#homedir#$HHH#g"  aave.gs.com > tmp1
 sed "s/variable/$var/g"           tmp1 > tmp2
 sed "s/num_t/$TTT/g"              tmp2 > tmp1
 sed "s/beg_lon/$BLO/g"            tmp1 > tmp2
 sed "s/end_lon/$ELO/g"            tmp2 > tmp1
 sed "s/beg_lat/$BLA/g"            tmp1 > tmp2
 sed "s/end_lat/$ELA/g"            tmp2 > tmp1
 sed "s/region/$reg/g"             tmp1 > tmp2
 sed "s/season/$sea/g"             tmp2 > tmp1
 sed "s/period/$PPP/g"             tmp1 > aave.gs
# cp aave.gs aave2.gs
grads -lb << EOF
aave 
EOF

 sed "s/num_t/$TTT/g"   aave.ctl.com > tmp1
 sed "s/region/$reg/g"             tmp1 > tmp2
 sed "s/season/$sea/g"             tmp2 > tmp1
 sed "s/missing/$MMM/g"            tmp1 > $reg.$sea.series.ctl
 cp -f *ctl $HHH/level_1/$var/data/.

# Area averaging!
#   end 
   done

  elif [ $sea == 'sum' ]; then

   for reg in IO WP BB
   do
    if [ $reg == 'IO' ]; then
      export BLO=75 
      export ELO=100
      export BLA=-10
      export ELA=5
    elif [ $reg == 'WP' ]; then
      export BLO=115
      export ELO=140
      export BLA=10
      export ELA=25
    elif [ $reg == 'BB' ]; then
      export BLO=80
      export ELO=100
      export BLA=10
      export ELA=20
    fi
# Area averaging!
 sed "s#homedir#$HHH#g"  aave.gs.com > tmp1
 sed "s/variable/$var/g"           tmp1 > tmp2
 sed "s/num_t/$TTT/g"              tmp2 > tmp1
 sed "s/beg_lon/$BLO/g"            tmp1 > tmp2
 sed "s/end_lon/$ELO/g"            tmp2 > tmp1
 sed "s/beg_lat/$BLA/g"            tmp1 > tmp2
 sed "s/end_lat/$ELA/g"            tmp2 > tmp1
 sed "s/region/$reg/g"             tmp1 > tmp2
 sed "s/season/$sea/g"             tmp2 > tmp1
 sed "s/period/$PPP/g"             tmp1 > aave.gs
grads -lb << EOF
aave 
EOF

 sed "s/num_t/$TTT/g"   aave.ctl.com > tmp1
 sed "s/region/$reg/g"             tmp1 > tmp2
 sed "s/season/$sea/g"             tmp2 > tmp1
 sed "s/missing/$MMM/g"            tmp1 > $reg.$sea.series.ctl
 cp -f *ctl $HHH/level_1/$var/data/.

# Area averaging!
#   end 
   done

#  endif
  fi

 elif [ $MJO == 'U850' ]; then

  if [ $sea == 'win' ]; then

   for reg in IO WP 
   do
    if [ $reg == 'IO' ]; then
      export BLO 68.75
      export ELO 96.25
      export BLA -16.25
      export ELA -1.25
    elif [ $reg == 'WP' ]; then
      export BLO 163.75
      export ELO 191.25
      export BLA -13.75
      export ELA 1.25
    fi
# Area averaging!
 sed "s#homedir#$HHH#g"  aave.gs.com > tmp1
 sed "s/variable/$var/g"           tmp1 > tmp2
 sed "s/num_t/$TTT/g"              tmp2 > tmp1
 sed "s/beg_lon/$BLO/g"            tmp1 > tmp2
 sed "s/end_lon/$ELO/g"            tmp2 > tmp1
 sed "s/beg_lat/$BLA/g"            tmp1 > tmp2
 sed "s/end_lat/$ELA/g"            tmp2 > tmp1
 sed "s/region/$reg/g"             tmp1 > tmp2
 sed "s/season/$sea/g"             tmp2 > tmp1
 sed "s/period/$PPP/g"             tmp1 > aave.gs
grads -lb << EOF
aave 
EOF

 sed "s/num_t/$TTT/g"   aave.ctl.com > tmp1
 sed "s/region/$reg/g"             tmp1 > tmp2
 sed "s/season/$sea/g"             tmp2 > tmp1
 sed "s/missing/$MMM/g"            tmp1 > $reg.$sea.series.ctl
 cp -f *ctl $HHH/level_1/$var/data/.

# Area averaging!
#   end 
   done

  elif [ $sea == 'sum' ]; then

   for reg in IO WP EP 
   do
    if [ $reg == 'IO' ]; then
      export BLO=68.75
      export ELO=96.25
      export BLA=3.75
      export ELA=21.25
    elif [ $reg == 'WP' ]; then
      export BLO=118.75
      export ELO=146.25
      export BLA=3.75
      export ELA=21.25
    elif [ $reg == 'EP' ]; then
      export BLO=241.25
      export ELO=266.25
      export BLA=6.25
      export ELA=16.25
    fi
# Area averaging!
 sed "s#homedir#$HHH#g"  aave.gs.com > tmp1
 sed "s/variable/$var/g"           tmp1 > tmp2
 sed "s/num_t/$TTT/g"              tmp2 > tmp1
 sed "s/beg_lon/$BLO/g"            tmp1 > tmp2
 sed "s/end_lon/$ELO/g"            tmp2 > tmp1
 sed "s/beg_lat/$BLA/g"            tmp1 > tmp2
 sed "s/end_lat/$ELA/g"            tmp2 > tmp1
 sed "s/region/$reg/g"             tmp1 > tmp2
 sed "s/season/$sea/g"             tmp2 > tmp1
 sed "s/period/$PPP/g"             tmp1 > aave.gs
grads -lb << EOF
aave 
EOF

 sed "s/num_t/$TTT/g"   aave.ctl.com > tmp1
 sed "s/region/$reg/g"             tmp1 > tmp2
 sed "s/season/$sea/g"             tmp2 > tmp1
 sed "s/missing/$MMM/g"            tmp1 > $reg.$sea.series.ctl
 cp -f *ctl $HHH/level_1/$var/data/.

# Area averaging!
#   end 
   done

#  endif
  fi

 elif [ $MJO == 'U200' ]; then

  if [ $sea == 'win' ]; then

   for reg in IO WP EP
   do
    if [ $reg == 'IO' ]; then
      export BLO 56.25
      export ELO 78.75
      export BLA 3.75
      export ELA 21.25
    elif [ $reg == 'WP' ]; then
      export BLO 123.75
      export ELO 151.25
      export BLA 3.75
      export ELA 21.25
    elif [ $reg == 'EP' ]; then
      export BLO 256.25
      export ELO 278.75
      export BLA -16.25
      export ELA 1.25
    fi
# Area averaging!
 sed "s#homedir#$HHH#g"  aave.gs.com > tmp1
 sed "s/variable/$var/g"           tmp1 > tmp2
 sed "s/num_t/$TTT/g"              tmp2 > tmp1
 sed "s/beg_lon/$BLO/g"            tmp1 > tmp2
 sed "s/end_lon/$ELO/g"            tmp2 > tmp1
 sed "s/beg_lat/$BLA/g"            tmp1 > tmp2
 sed "s/end_lat/$ELA/g"            tmp2 > tmp1
 sed "s/region/$reg/g"             tmp1 > tmp2
 sed "s/season/$sea/g"             tmp2 > tmp1
 sed "s/period/$PPP/g"             tmp1 > aave.gs
grads -lb << EOF
aave 
EOF

 sed "s/num_t/$TTT/g"   aave.ctl.com > tmp1
 sed "s/region/$reg/g"             tmp1 > tmp2
 sed "s/season/$sea/g"             tmp2 > tmp1
 sed "s/missing/$MMM/g"            tmp1 > $reg.$sea.series.ctl
 cp -f *ctl $HHH/level_1/$var/data/.

# Area averaging!
#   end 
   done

  elif [ $sea == 'sum' ]; then

   for reg in IO WP EP
   do
    if [ $reg == 'IO' ]; then
      export BLO=43.75
      export ELO=71.25
      export BLA=-16.25
      export ELA=1.25
    elif [ $reg == 'WP' ]; then
      export BLO=123.75
      export ELO=151.25
      export BLA=3.75
      export ELA=21.25
    elif [ $reg == 'EP' ]; then
      export BLO=238.75
      export ELO=266.25
      export BLA=-16.25
      export ELA=1.25
    fi
# Area averaging!
 sed "s#homedir#$HHH#g"  aave.gs.com > tmp1
 sed "s/variable/$var/g"           tmp1 > tmp2
 sed "s/num_t/$TTT/g"              tmp2 > tmp1
 sed "s/beg_lon/$BLO/g"            tmp1 > tmp2
 sed "s/end_lon/$ELO/g"            tmp2 > tmp1
 sed "s/beg_lat/$BLA/g"            tmp1 > tmp2
 sed "s/end_lat/$ELA/g"            tmp2 > tmp1
 sed "s/region/$reg/g"             tmp1 > tmp2
 sed "s/season/$sea/g"             tmp2 > tmp1
 sed "s/period/$PPP/g"             tmp1 > aave.gs
grads -lb << EOF
aave 
EOF

 sed "s/num_t/$TTT/g"   aave.ctl.com > tmp1
 sed "s/region/$reg/g"             tmp1 > tmp2
 sed "s/season/$sea/g"             tmp2 > tmp1
 sed "s/missing/$MMM/g"            tmp1 > $reg.$sea.series.ctl
 cp -f *ctl $HHH/level_1/$var/data/.

# Area averaging!
#   end 
   done

  fi

# MJO
 fi

# season
 done

# var
 done

