#!/bin/sh

# HHH  : home directory
# MJO  : variable (e.g. OLR, PRCP)
# TVA  : title
# TSE  : title (season)
# TTT  : total number of time
# LVS  : contour levels 
# CIN  : contour interval
# SN1~4: sign of 1st to 4th modes (for EOF plot)
# MOR  : order of modes in plot
#  (1: 1,2,3,4  2: 2,1,3,4  3: 1,2,4,3)

 source ../../env.sh

 for var in olr_av u850_n1 u200_n1
# for var in olr_av
 do

# variable
 if [ $var == 'olr_av' ]; then
  export MJO=OLR
  export TVA='OLR(AVHRR)'
  export MOR=1
  export YRA=100
  export YIN=20
 elif [ $var == 'u850_n1' ]; then
  export MJO=U850
  export TVA='U850(NCEP1)'
  export MOR=1
  export YRA=4
  export YIN=0.8
 elif [ $var == 'u200_n1' ]; then
  export MJO=U200
  export TVA='U200(NCEP1)'
  export MOR=1
  export YRA=20
  export YIN=4
 fi

# contour interval
 if [ $MJO == 'OLR' ]; then
  export LVS='-18 -16 -14 -12 -10 -8 -6 -4 -2 2 4 6 8 10 12 14 16 18'
  export CIN=2
 elif [ $MJO == 'PRCP' ]; then
  export LVS='-4.5 -4.0 -3.5 -3.0 -2.5 -2.0 -1.5 -1.0 -0.5 0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5'
  export CIN=0.5
 elif [ $MJO == 'U850' ]; then
  export LVS='-2.7 -2.4 -2.1 -1.8 -1.5 -1.2 -0.9 -0.6 -0.3 0.3 0.6 0.9 1.2 1.5 1.8 2.1 2.4 2.7'
  export CIN=0.3
 elif [ $MJO == 'U200' ]; then
  export LVS='-4.5 -4.0 -3.5 -3.0 -2.5 -2.0 -1.5 -1.0 -0.5 0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5'
  export CIN=0.5
 fi

 for sea in sum win
# for sea in sum 
 do

 if [ $sea == 'win' ]; then
  export TSE='Winter (Nov-Apr)'

   #export TTT 4713
   #export TTT 1269
   export TTT=1088
  if [ $var == 'olr_av' ]; then
   #export TTT 4713
   export SN1=1
   export SN2=-1
   export SN3=1
   export SN4=1
  elif [ $var == 'u850_n1' ]; then
   #export TTT 4713
   export SN1=-1
   export SN2=1
   export SN3=1
   export SN4=1
  elif [ $var == 'u200_n1' ]; then
   #export TTT 4713
   export SN1=-1
   export SN2=-1
   export SN3=1
   export SN4=1
  fi

 elif [ $sea == 'sum' ]; then
  export TSE='Summer (May-Oct)'

   #export TTT 4968
   #export TTT 1288
   export TTT=1288
  if [ $var == 'olr_av' ]; then
   #export TTT 4968
   export SN1=1
   export SN2=-1
   export SN3=1
   export SN4=1
  elif [ $var == 'u850_n1' ]; then
   #export TTT 4968
   export SN1=1
   export SN2=1
   export SN3=1
   export SN4=1
  elif [ $var == 'u200_n1' ]; then
   #export TTT 4968
   export SN1=-1
   export SN2=-1
   export SN3=1
   export SN4=1
  fi

 fi

# EOFs

# file copy
 cd $HHH/level_1/$var/eof/$sea
 cp -f $HHH/level_1/com/eof/eof.gs.com .

 sed "s#homedir#$HHH#g"                   eof.gs.com > tmp1
 sed "s/variable/$var/g"                           tmp1 > tmp2
 sed "s/season/$sea/g"                             tmp2 > tmp1
 sed "s/title_sea/$TSE/g"                          tmp1 > tmp2
 sed "s/title_var/$TVA/g"                          tmp2 > tmp1
 sed "s/n_time/$TTT/g"                             tmp1 > tmp2
 sed "s/ppe1/$SN1*ev1/g"                           tmp2 > tmp1
 sed "s/ppe2/$SN2*ev2/g"                           tmp1 > tmp2
 sed "s/ppe3/$SN3*ev3/g"                           tmp2 > tmp1
 sed "s/ppe4/$SN4*ev4/g"                           tmp1 > tmp2
 sed "s/mode_order/$MOR/g"                         tmp2 > tmp1
 sed "s/levels/$LVS/g"                             tmp1 > tmp2
 sed "s/c_int/$CIN/g"                              tmp2 > eof.gs

grads -pb << EOF
eof
EOF

# percentage variance
 cp -f $HHH/level_1/com/eof/pct.gs.com .
 sed "s/season/$sea/g"                    pct.gs.com > tmp1
 sed "s/title_sea/$TSE/g"                          tmp1 > tmp2
 sed "s/title_var/$TVA/g"                          tmp2 > pct.gs

grads -lb << EOF
pct
EOF

# power spectra
 cp -f $HHH/level_1/com/eof/power.gs.com .
 cp -f $HHH/level_1/com/eof/power.dummy .
 cp -f $HHH/level_1/com/eof/power.dummy.ctl .

 for exp in 01 02 03 04 05 
 do
  sed "s/season/$sea/g"                  power.gs.com > tmp1
  sed "s/title_sea/$TSE/g"                          tmp1 > tmp2
  sed "s/title_var/$TVA/g"                          tmp2 > tmp1
  sed "s/number/$exp/g"                             tmp1 > tmp2
  sed "s/y_ran/$YRA/g"                              tmp2 > tmp1
  sed "s/y_int/$YIN/g"                              tmp1 > power.gs

grads -lb << EOF
power.gs pcps.ts$exp
EOF
# end
 done

# copy gif file
 mkdir -p $HHH/level_1/fig/eof/$var
# cp -f eof.$sea.gif $HHH/level_1/fig/eof/$var/.
 cp -f eof.$sea.png $HHH/level_1/fig/eof/$var/.
# cp -f pct.$sea.gif $HHH/level_1/fig/eof/$var/.
 cp -f pct.$sea.png $HHH/level_1/fig/eof/$var/.
# cp -f pcps.*.$sea.gif $HHH/level_1/fig/eof/$var/.
 cp -f pcps.*.$sea.png $HHH/level_1/fig/eof/$var/.
 
# end
 done
# foreach sea

# end 
 done
# foreach var

