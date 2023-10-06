#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data
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

# please use data from 01janYYYY to 31decYYYY

 export BYY=1979
 export LYR=1
# export LNX=4
 export MMM=-9.99e8

 export NYR=7
 ((NYR1=NYR-1))

 cd $HHH/level_1/$var

 mkdir -p src/eof
 cd src/eof

 cp -f $HHH/level_1/com/eof/power.f90.com .
 cp -f $HHH/level_1/com/eof/makefile .
# cp -f $HHH/level_1/com/eof/libfftpack.a .
 cp -f $HHH/tools/fftpack/libfftpack.a .

 for sea in win sum 
 do

 if [ $sea == 'win' ]; then

# ! time series power spectrum #####################
 sed "s#homedir#$HHH#g" power.f90.com > tmp1
 sed "s/mjo_var/$var/g"           tmp1 > tmp2
 sed "s/sea_name/$sea/g"          tmp2 > tmp1
 sed "s/num_r/$NYR1/g"            tmp1 > tmp2
 sed "s/sea_num/1/g"              tmp2 > tmp1
 sed "s/beg_year/$BYY/g"          tmp1 > tmp2
 sed "s/leap_year/$LYR/g"         tmp2 > tmp1
 sed "s/linux_recl/$LNX/g"        tmp1 > tmp2
 sed "s/missing/$MMM/g"           tmp2 > power.f90

 echo $sea
 make
./power
 rm -f power power.f power.o
####################################################

 elif [ $sea == 'sum' ]; then

# ! time series power spectrum #####################
 sed "s#homedir#$HHH#g" power.f90.com > tmp1
 sed "s/mjo_var/$var/g"           tmp1 > tmp2
 sed "s/sea_name/$sea/g"          tmp2 > tmp1
 sed "s/num_r/$NYR/g"             tmp1 > tmp2
 sed "s/sea_num/2/g"              tmp2 > tmp1
 sed "s/beg_year/$BYY/g"          tmp1 > tmp2
 sed "s/leap_year/$LYR/g"         tmp2 > tmp1
 sed "s/linux_recl/$LNX/g"        tmp1 > tmp2
 sed "s/missing/$MMM/g"           tmp2 > power.f90

 echo $sea
 make
./power
 rm -f power power.f power.o
####################################################

# endif
 fi

# season
# end
 done

# var
# end
 done

