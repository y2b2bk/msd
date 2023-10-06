#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data
# DDD  : number of days per 1 year (for models using 360 day calendar)
# BYY  : first year (e.g. 1979)
# NYR  : number of years (e.g. 27 for 1979-2005)
# NYR1 : NYR - 1
# LYR  : whether the data has leap year or not
#  (e.g. 1 : leap year, 0 : no leap year)
# LNX  : whether the machine is linux or not
#  This is for the record length problem.
#  (e.g. 4 : linux machine, 1 : other machine)
# MMM  : missing value
# PPP  : period of data

 source ../../env.sh

 for var in olr_av u850_n1 u200_n1
 do

 export DDD=365
 export SSS=1
 export EEE=365
# current version does not condider SSS and EEE
# please use data from 01janYYYY to 31decYYYY

 export BYY=1979
 export EYY=1985
 export LYR=1
# export LNX=4
 export MMM=-9.99e8
 export PPP=19790101_19851231

 export NYR=7
 ((NYR1=NYR-1))

 if [ $var == 'olr_av' ]; then
   export MJO=OLR
 elif [ $var == 'u850_n1' ]; then
   export MJO=U850
 elif [ $var == 'u200_n1' ]; then
   export MJO=U200
 fi

 cd $HHH/level_1/$var

# output directory
 mkdir -p tsps

# source directory
 mkdir -p src/tsps
 cd src/tsps

 cp -f $HHH/level_1/com/tsps/power.f90.com .
 cp -f $HHH/tools/fftpack/libfftpack.a .
 cp -f $HHH/level_1/com/tsps/makefile .

 for sea in win sum 
 do

 if [ $MJO == 'OLR' ]; then

  if [ $sea == 'win' ]; then
   for reg in IO WP MC
   do

# ! time series power spectrum #####################
 sed "s#homedir#$HHH#g" power.f90.com > tmp1
 sed "s/mjo_var/$var/g"           tmp1 > tmp2
 sed "s/num_r/$NYR1/g"            tmp2 > tmp1
 sed "s/sea_num/1/g"              tmp1 > tmp2
 sed "s/beg_year/$BYY/g"          tmp2 > tmp1
 sed "s/leap_year/$LYR/g"         tmp1 > tmp2
 sed "s/linux_recl/$LNX/g"        tmp2 > tmp1
 sed "s/in_name/$reg.$sea/g"      tmp1 > tmp2
 sed "s/missing/$MMM/g"           tmp2 > tmp1
 sed "s/num_d/$DDD/g"             tmp1 > power.f90

 make 
./power
 rm -f power power.f90 power.o
####################################################
#   end
   done
  elif [ $sea == 'sum' ]; then
   for reg in IO WP BB
   do
# ! time series power spectrum #####################
 sed "s#homedir#$HHH#g" power.f90.com > tmp1
 sed "s/mjo_var/$var/g"           tmp1 > tmp2
 sed "s/num_r/$NYR/g"             tmp2 > tmp1
 sed "s/sea_num/2/g"              tmp1 > tmp2
 sed "s/beg_year/$BYY/g"          tmp2 > tmp1
 sed "s/leap_year/$LYR/g"         tmp1 > tmp2
 sed "s/linux_recl/$LNX/g"        tmp2 > tmp1
 sed "s/in_name/$reg.$sea/g"      tmp1 > tmp2
 sed "s/missing/$MMM/g"           tmp2 > tmp1
 sed "s/num_d/$DDD/g"             tmp1 > power.f90

 make 
./power
 rm -f power power.f90 power.o
####################################################
#   end
   done
#  endif
  fi

 elif [ $MJO == 'U850' ]; then

  if [ $sea == 'win' ]; then

   for reg in IO WP
   do
# ! time series power spectrum #####################
 sed "s#homedir#$HHH#g" power.f90.com > tmp1
 sed "s/mjo_var/$var/g"           tmp1 > tmp2
 sed "s/num_r/$NYR1/g"            tmp2 > tmp1
 sed "s/sea_num/1/g"              tmp1 > tmp2
 sed "s/beg_year/$BYY/g"          tmp2 > tmp1
 sed "s/leap_year/$LYR/g"         tmp1 > tmp2
 sed "s/linux_recl/$LNX/g"        tmp2 > tmp1
 sed "s/in_name/$reg.$sea/g"      tmp1 > tmp2
 sed "s/missing/$MMM/g"           tmp2 > tmp1
 sed "s/num_d/$DDD/g"             tmp1 > power.f90

 make
./power
 rm -f power power.f90 power.o
####################################################
#   end
   done

  elif [ $sea == 'sum' ]; then

   for reg in  IO WP EP
   do
# ! time series power spectrum #####################
 sed "s#homedir#$HHH#g" power.f90.com > tmp1
 sed "s/mjo_var/$var/g"           tmp1 > tmp2
 sed "s/num_r/$NYR/g"             tmp2 > tmp1
 sed "s/sea_num/2/g"              tmp1 > tmp2
 sed "s/beg_year/$BYY/g"          tmp2 > tmp1
 sed "s/leap_year/$LYR/g"         tmp1 > tmp2
 sed "s/linux_recl/$LNX/g"        tmp2 > tmp1
 sed "s/in_name/$reg.$sea/g"      tmp1 > tmp2
 sed "s/missing/$MMM/g"           tmp2 > tmp1
 sed "s/num_d/$DDD/g"             tmp1 > power.f90

 make
./power
 rm -f power power.f90 power.o
####################################################
#   end
   done

#  endif
  fi

 elif [ $MJO == 'U200' ]; then

  if [ $sea == 'win' ]; then

   for reg in IO WP EP 
   do
# ! time series power spectrum #####################
 sed "s#homedir#$HHH#g" power.f90.com > tmp1
 sed "s/mjo_var/$var/g"           tmp1 > tmp2
 sed "s/num_r/$NYR1/g"            tmp2 > tmp1
 sed "s/sea_num/1/g"              tmp1 > tmp2
 sed "s/beg_year/$BYY/g"          tmp2 > tmp1
 sed "s/leap_year/$LYR/g"         tmp1 > tmp2
 sed "s/linux_recl/$LNX/g"        tmp2 > tmp1
 sed "s/in_name/$reg.$sea/g"      tmp1 > tmp2
 sed "s/missing/$MMM/g"           tmp2 > tmp1
 sed "s/num_d/$DDD/g"             tmp1 > power.f90

 make
./power
 rm -f power power.f90 power.o
####################################################
#   end
   done

  elif [ $sea == 'sum' ]; then

   for reg in IO WP EP
   do
# ! time series power spectrum #####################
 sed "s#homedir#$HHH#g" power.f90.com > tmp1
 sed "s/mjo_var/$var/g"           tmp1 > tmp2
 sed "s/num_r/$NYR/g"             tmp2 > tmp1
 sed "s/sea_num/2/g"              tmp1 > tmp2
 sed "s/beg_year/$BYY/g"          tmp2 > tmp1
 sed "s/leap_year/$LYR/g"         tmp1 > tmp2
 sed "s/linux_recl/$LNX/g"        tmp2 > tmp1
 sed "s/in_name/$reg.$sea/g"      tmp1 > tmp2
 sed "s/missing/$MMM/g"           tmp2 > tmp1
 sed "s/num_d/$DDD/g"             tmp1 > power.f90

 make
./power
 rm -f power power.f90 power.o
####################################################
   done

  fi

# if - MJO
  fi

# foreach - season
 done

# foreach - var
 done

