#!/bin/sh
set -vx

# HHH  : home directory
# var  : name of data

 source ../../env.sh

 for var in olr_av u850_n1 u200_n1
 do

# variable
 if [ $var == 'olr_av' ]; then
  export MJO=OLR
  export TVA='OLR(AVHRR)'
 elif [ $var == 'u850_n1' ]; then
  export MJO=U850
  export TVA='U850(NCEP1)'
 elif [ $var == 'u200_n1' ]; then
  export MJO=U200
  export TVA='U200(NCEP1)'
 fi

 if [ $MJO == 'OLR' ]; then
  export YRA=2.5
  export YIT=0.5
 elif [ $MJO == 'U850' ]; then
  export YRA=0.05
  export YIT=0.01
 elif [ $MJO == 'U200' ]; then
  export YRA=0.24
  export YIT=0.04
 fi

# file copy
 cd $HHH/level_1/$var
 cd tsps
 pwd

 cp -f $HHH/level_1/com/tsps/tsps.gs.com .
 cp -f $HHH/level_1/com/tsps/power.dummy .
 cp -f $HHH/level_1/com/tsps/power.dummy.ctl .

 for sea in win sum 
 do

 if [ $sea == 'win' ]; then
  export TSE='Winter (Nov-Apr)'
 elif [ $sea == 'sum' ]; then
  export TSE='Summer (May-Oct)'
 fi

 if [ $MJO == 'OLR' ]; then

  if [ $sea == 'win' ]; then

   for reg in IO WP MC 
   do

    if [ $reg == 'IO' ]; then
      export BLO=75E
      export ELO=100E
      export BLA=10S
      export ELA=5N
    elif [ $reg == 'WP' ]; then
      export BLO=160E
      export ELO=185E
      export BLA=20S
      export ELA=5S
    elif [ $reg == 'MC' ]; then
      export BLO=115E
      export ELO=145E
      export BLA=17.5S
      export ELA=2.5S
    fi
# ! plot time series power spectrum #############################
 sed "s#homedir#$HHH#g"  tsps.gs.com > tmp1
 sed "s/variable/$var/g"           tmp1 > tmp2
 sed "s/variable/$var/g"           tmp1 > tmp2
 sed "s/season/$sea/g"             tmp2 > tmp1
 sed "s/beg_lon/$BLO/g"            tmp1 > tmp2
 sed "s/end_lon/$ELO/g"            tmp2 > tmp1
 sed "s/beg_lat/$BLA/g"            tmp1 > tmp2
 sed "s/end_lat/$ELA/g"            tmp2 > tmp1
 sed "s/region/$reg/g"             tmp1 > tmp2
 sed "s/title_sea/$TSE/g"          tmp2 > tmp1
 sed "s/title_var/$TVA/g"          tmp1 > tmp2
 sed "s/y_ran/$YRA/g"              tmp2 > tmp1
 sed "s/y_int/$YIT/g"              tmp1 > tsps.gs

grads -lb << EOF
tsps.gs $reg.$sea
EOF

# move gif files
 mkdir -p $HHH/level_1/fig/tsps/$var
# cp -f $reg.$sea.gif $HHH/level_1/fig/tsps/$var/.
 cp -f $reg.$sea.png $HHH/level_1/fig/tsps/$var/.

#################################################################
#   end
   done

  elif [ $sea == 'sum' ]; then

   for reg in IO WP BB 
   do
    if [ $reg == 'IO' ]; then
      export BLO=75E
      export ELO=100E
      export BLA=10S
      export ELA=5N
    elif [ $reg == 'WP' ]; then
      export BLO=115E
      export ELO=140E
      export BLA=10N
      export ELA=25N
    elif [ $reg == 'BB' ]; then
      export BLO=80E
      export ELO=100E
      export BLA=10N
      export ELA=20N
    fi
# ! plot time series power spectrum #############################
 sed "s#homedir#$HHH#g"  tsps.gs.com > tmp1
 sed "s/variable/$var/g"           tmp1 > tmp2
 sed "s/season/$sea/g"             tmp2 > tmp1
 sed "s/beg_lon/$BLO/g"            tmp1 > tmp2
 sed "s/end_lon/$ELO/g"            tmp2 > tmp1
 sed "s/beg_lat/$BLA/g"            tmp1 > tmp2
 sed "s/end_lat/$ELA/g"            tmp2 > tmp1
 sed "s/region/$reg/g"             tmp1 > tmp2
 sed "s/title_sea/$TSE/g"          tmp2 > tmp1
 sed "s/title_var/$TVA/g"          tmp1 > tmp2
 sed "s/y_ran/$YRA/g"              tmp2 > tmp1
 sed "s/y_int/$YIT/g"              tmp1 > tsps.gs

grads -lb << EOF
tsps.gs $reg.$sea
EOF

# move gif files
 mkdir -p $HHH/level_1/fig/tsps/$var
# cp -f $reg.$sea.gif $HHH/level_1/fig/tsps/$var/.
 cp -f $reg.$sea.png $HHH/level_1/fig/tsps/$var/.

#################################################################
#   end
   done

#  endif
  fi

 elif [ $MJO == 'U850' ]; then

  if [ $sea == 'win' ]; then

   for reg in IO WP 
   do
    if [ $reg == 'IO' ]; then
    export BLO=68.75E
    export ELO=96.25E
    export BLA=16.25S
    export ELA=1.25S
    elif [ $reg == 'WP' ]; then
    export BLO=163.75E
    export ELO=191.25E
    export BLA=13.75S
    export ELA=1.25N
    fi
# ! plot time series power spectrum #############################
 sed "s#homedir#$HHH#g"  tsps.gs.com > tmp1
 sed "s/variable/$var/g"           tmp1 > tmp2
 sed "s/season/$sea/g"             tmp2 > tmp1
 sed "s/beg_lon/$BLO/g"            tmp1 > tmp2
 sed "s/end_lon/$ELO/g"            tmp2 > tmp1
 sed "s/beg_lat/$BLA/g"            tmp1 > tmp2
 sed "s/end_lat/$ELA/g"            tmp2 > tmp1
 sed "s/region/$reg/g"             tmp1 > tmp2
 sed "s/title_sea/$TSE/g"          tmp2 > tmp1
 sed "s/title_var/$TVA/g"          tmp1 > tmp2
 sed "s/y_ran/$YRA/g"              tmp2 > tmp1
 sed "s/y_int/$YIT/g"              tmp1 > tsps.gs

grads -lb << EOF
tsps.gs $reg.$sea
EOF

# move gif files
 mkdir -p $HHH/level_1/fig/tsps/$var
# cp -f $reg.$sea.gif $HHH/level_1/fig/tsps/$var/.
 cp -f $reg.$sea.png $HHH/level_1/fig/tsps/$var/.

#################################################################

#   end
   done

  elif [ $sea == 'sum' ]; then

   for reg in IO WP EP 
   do
    if [ $reg == 'IO' ]; then
      export BLO=68.75E
      export ELO=96.25E
      export BLA=3.75N
      export ELA=21.25N
    elif [ $reg == 'WP' ]; then
      export BLO=118.75E
      export ELO=146.25E
      export BLA=3.75N
      export ELA=21.25N
    elif [ $reg == 'EP' ]; then
      export BLO=241.25E
      export ELO=266.25E
      export BLA=6.25N
      export ELA=16.25N
    fi
# ! plot time series power spectrum #############################
 sed "s#homedir#$HHH#g"  tsps.gs.com > tmp1
 sed "s/variable/$var/g"           tmp1 > tmp2
 sed "s/season/$sea/g"             tmp2 > tmp1
 sed "s/beg_lon/$BLO/g"            tmp1 > tmp2
 sed "s/end_lon/$ELO/g"            tmp2 > tmp1
 sed "s/beg_lat/$BLA/g"            tmp1 > tmp2
 sed "s/end_lat/$ELA/g"            tmp2 > tmp1
 sed "s/region/$reg/g"             tmp1 > tmp2
 sed "s/title_sea/$TSE/g"          tmp2 > tmp1
 sed "s/title_var/$TVA/g"          tmp1 > tmp2
 sed "s/y_ran/$YRA/g"              tmp2 > tmp1
 sed "s/y_int/$YIT/g"              tmp1 > tsps.gs

grads -lb << EOF
tsps.gs $reg.$sea
EOF

# move gif files
 mkdir -p $HHH/level_1/fig/tsps/$var
# cp -f $reg.$sea.gif $HHH/level_1/fig/tsps/$var/.
 cp -f $reg.$sea.png $HHH/level_1/fig/tsps/$var/.

#################################################################

#   end
   done

#  endif
  fi

 elif [ $MJO == 'U200' ]; then

  if [ $sea == 'win' ]; then

   for reg in IO WP EP 
   do
    if [ $reg == 'IO' ]; then
      export BLO=56.25E
      export ELO=78.75E
      export BLA=3.75N
      export ELA=21.25N
    elif [ $reg == 'WP' ]; then
      export BLO=123.75E
      export ELO=151.25E
      export BLA=3.75N
      export ELA=21.25N
    elif [ $reg == 'EP' ]; then
      export BLO=256.25E
      export ELO=278.75E
      export BLA=16.25S
      export ELA=1.25N
    fi
# ! plot time series power spectrum #############################
 sed "s#homedir#$HHH#g"  tsps.gs.com > tmp1
 sed "s/variable/$var/g"           tmp1 > tmp2
 sed "s/season/$sea/g"             tmp2 > tmp1
 sed "s/beg_lon/$BLO/g"            tmp1 > tmp2
 sed "s/end_lon/$ELO/g"            tmp2 > tmp1
 sed "s/beg_lat/$BLA/g"            tmp1 > tmp2
 sed "s/end_lat/$ELA/g"            tmp2 > tmp1
 sed "s/region/$reg/g"             tmp1 > tmp2
 sed "s/title_sea/$TSE/g"          tmp2 > tmp1
 sed "s/title_var/$TVA/g"          tmp1 > tmp2
 sed "s/y_ran/$YRA/g"              tmp2 > tmp1
 sed "s/y_int/$YIT/g"              tmp1 > tsps.gs

grads -lb << EOF
tsps.gs $reg.$sea
EOF

# move gif files
 mkdir -p $HHH/level_1/fig/tsps/$var
# cp -f $reg.$sea.gif $HHH/level_1/fig/tsps/$var/.
 cp -f $reg.$sea.png $HHH/level_1/fig/tsps/$var/.

#################################################################
#   end
   done

  elif [ $sea == 'sum' ]; then

   for reg in IO WP EP 
   do
    if [ $reg == 'IO' ]; then
      export BLO=43.75E
      export ELO=71.25E
      export BLA=16.25S
      export ELA=1.25N
    elif [ $reg == 'WP' ]; then
      export BLO=123.75E
      export ELO=151.25E
      export BLA=3.75N
      export ELA=21.25N
    elif [ $reg == 'EP' ]; then
      export BLO=238.75E
      export ELO=266.25E
      export BLA=16.25S
      export ELA=1.25N
    fi
# ! plot time series power spectrum #############################
 sed "s#homedir#$HHH#g"  tsps.gs.com > tmp1
 sed "s/variable/$var/g"           tmp1 > tmp2
 sed "s/season/$sea/g"             tmp2 > tmp1
 sed "s/beg_lon/$BLO/g"            tmp1 > tmp2
 sed "s/end_lon/$ELO/g"            tmp2 > tmp1
 sed "s/beg_lat/$BLA/g"            tmp1 > tmp2
 sed "s/end_lat/$ELA/g"            tmp2 > tmp1
 sed "s/region/$reg/g"             tmp1 > tmp2
 sed "s/title_sea/$TSE/g"          tmp2 > tmp1
 sed "s/title_var/$TVA/g"          tmp1 > tmp2
 sed "s/y_ran/$YRA/g"              tmp2 > tmp1
 sed "s/y_int/$YIT/g"              tmp1 > tsps.gs

grads -lb << EOF
tsps.gs $reg.$sea
EOF

# move gif files
 mkdir -p $HHH/level_1/fig/tsps/$var
# cp -f $reg.$sea.gif $HHH/level_1/fig/tsps/$var/.
 cp -f $reg.$sea.png $HHH/level_1/fig/tsps/$var/.

#################################################################
   done

  fi

# MJO
 fi

# season
 done

# var
 done




