#!/bin/sh
set -vx

# 1. CEOFs
# 2. percentage variance
# 3. lag corr. bet. PC1 and PC2
# 4. cross spectra bet. PC1 and PC2

# HHH  : home directory
# TVA  : title
# TSE  : title (season)
# SN1, SN2 : sign of PCs (for lag corr.)
# MOR  : order of modes
#  (e.g. 1: 1 -> 2, 2: 2 -> 1)
# PPP  : period
# YRA  : y-range (for power spectra)
# YIN  : y-interval (for power spectra)

 source ../../../env.sh

 for var in ceof 
 do

#  export TTT=9862
  export TTT=2557
  export TVA='Combined EOF'
  export TSE='All season'
  export SN1=1
  export SN2=-1
  export MOR=1
#  export PPP=1979-2005
  export PPP=1979-1985
 
  export YRA=4
  export YIN=0.5

# file copy
 cd $HHH/level_2/$var
 cp -f $HHH/level_2/com/ceof/ceof.gs.com .

 sed "s#homedir#$HHH#g"             ceof.gs.com > tmp1
 sed "s/title_sea/$TSE/g"                     tmp1 > tmp2
 sed "s/title_var/$TVA/g"                     tmp2 > tmp1
 sed "s/n_time/$TTT/g"                        tmp1 > tmp2
 sed "s/e1/$SN1*ev1/g"                        tmp2 > tmp1
 sed "s/e2/$SN2*ev2/g"                        tmp1 > tmp2
 sed "s/mode_order/$MOR/g"                    tmp2 > tmp1
 sed "s/period/$PPP/g"                        tmp1 > ceof.gs

grads -pbc << EOF
ceof
EOF

# percentage variance
 cp -f $HHH/level_2/com/ceof/pct.gs.com .
 sed "s/title_sea/$TSE/g"                 pct.gs.com > tmp2
 sed "s/title_var/$TVA/g"                          tmp2 > pct.gs

grads -lb << EOF
pct
EOF

# pcl
 cp -f $HHH/level_2/com/ceof/pcl.gs.com .

 sed "s#homedir#$HHH#g"                   pcl.gs.com > tmp1
 sed "s/variable/$var/g"                           tmp1 > tmp2
 sed "s/title_sea/$TSE/g"                          tmp2 > tmp1
 sed "s/title_var/$TVA/g"                          tmp1 > pcl.gs

grads -lb << EOF
pcl
EOF

# sp256
 cp -f $HHH/level_2/com/ceof/power.gs.com .
 cp -f $HHH/level_2/com/ceof/power.dummy .
 cp -f $HHH/level_2/com/ceof/power.dummy.ctl .

 for exp in 1 2 
 do
  sed "s/title_sea/$TSE/g"           power.gs.com > tmp1
  sed "s/number/$exp/g"                         tmp1 > tmp2
  sed "s/y_ran/$YRA/g"                          tmp2 > tmp1
  sed "s/y_int/$YIN/g"                          tmp1 > power.gs

grads -lb << EOF
power.gs sp256.ts0$exp
EOF

# end
 done

# crsp
 cp -f $HHH/level_2/com/ceof/crsp.gs.com .
 cp -f $HHH/level_2/com/ceof/power.dummy .
 cp -f $HHH/level_2/com/ceof/power.dummy.ctl .

 sed "s/title_sea/$TSE/g"                crsp.gs.com > power.gs

grads -lb << EOF
power.gs crsp
EOF

# copy png
 mkdir -p $HHH/level_2/fig/ceof
 cp -f ceof.png $HHH/level_2/fig/ceof/.
 cp -f pct.png $HHH/level_2/fig/ceof/.
 cp -f pcl.png $HHH/level_2/fig/ceof/.
 cp -f sp256.*.png $HHH/level_2/fig/ceof/.
 cp -f crsp.png $HHH/level_2/fig/ceof/.

# end
 done
# foreach var
