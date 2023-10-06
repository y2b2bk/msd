#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data
# DDD  : number of days per 1 year (for models using 360 day calendar)
# TTT  : number of total time (in day) - total period
# BYY  : first year (e.g. 1979)
# NYR  : number of years (e.g. 27 for 1979-2005)
# NYR1 : NYR - 1
# LYR  : whether the data has leap year or not
#  (e.g. 1 : leap year, 0 : no leap year)
# LNX  : whether the machine is linux or not
#  This is for the record length problem.
#  (e.g. 4 : linux machine, 1 : other machine)
# MMM  : missing value

 source ../../env.sh

 for var in olr_av u850_n1 u200_n1
 do

 export DDD=365
 export BYY=1979
 export LYR=1
# export LNX=4
 export MMM=-9.99e8
 export PPP=19790101_19851231

 export NYR=7
 ((NYR1=NYR-1))

 cd $HHH/level_1/$var

# source directory
 mkdir -p src/pcl
 cd src/pcl

 cp -f $HHH/level_1/com/pcl/input.nml.com .
 cp -f $HHH/level_1/com/pcl/llreg_2d.f90 .

 for sea in win sum
 do

 if [ $sea == 'win' ]; then

  export SNN=1

   export TTT=1088
  if [ $var == 'olr_av' ]; then
   #export TTT 4713
   export SN1=1
   export SN2=-1
  elif [ $var == 'u850_n1' ]; then
   #export TTT 4713
   export SN1=1
   export SN2=1
  elif [ $var == 'u200_n1' ]; then
   #export TTT 4713
   export SN1=-1
   export SN2=-1
  fi

 elif [ $sea == 'sum' ]; then

  export SNN=2

   export TTT=1288
  if [ $var == 'olr_av' ]; then
   #export TTT 4968
   export SN1=1
   export SN2=-1
  elif [ $var == 'u850_n1' ]; then
   #export TTT 4968
   export SN1=-1
   export SN2=1
  elif [ $var == 'u200_n1' ]; then
   #export TTT 4968
   export SN1=-1
   export SN2=-1
  fi

 fi

 sed "s#homedir#$HHH#g"         input.nml.com > tmp1
 sed "s/variable/$var/g"                    tmp1 > tmp2
 sed "s/num_d/$DDD/g"                       tmp2 > tmp1
 sed "s/num_t/$TTT/g"                       tmp1 > tmp2
 sed "s/num_r/$NYR1/g"                      tmp2 > tmp1
 sed "s/sea_num/$SNN/g"                     tmp1 > tmp2
 sed "s/sea_name/$sea/g"                    tmp2 > tmp1
 sed "s/beg_year/$BYY/g"                    tmp1 > tmp2
 sed "s/leap_year/$LYR/g"                   tmp2 > tmp1
 sed "s/linux_recl/$LNX/g"                  tmp1 > tmp2
 sed "s/missing/$MMM/g"                     tmp2 > tmp1
 sed "s/sign1/$SN1/g"                       tmp1 > tmp2
 sed "s/sign2/$SN2/g"                       tmp2 > input.nml

$FC llreg_2d.f90
./a.out
rm -f a.out

#end 
done

#end
done
