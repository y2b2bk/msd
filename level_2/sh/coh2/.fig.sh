#!/bin/csh

 setenv HHH hdir

 foreach model ( mod_0 )

 foreach var ( vv_0 )

 if ( $var == 'u850_name' ) then
  setenv MJO U850
 else if ( $var == 'u200_name' ) then
  setenv MJO U200
 else if ( $var == 'usfc_name' ) then
  setenv MJO Usfc
 endif

 setenv tvar $model
 setenv PPP pp_0

# file copy
 cd $HHH/level_2
 mkdir -p fig/$model/coh2
 cd fig/$model/coh2
 cp -f $HHH/level_2/sample/coh2/exec.sample .

 sed "s#homedir#$HHH#g"                           exec.sample > tmp2
 sed "s/variable/$var/g"                                 tmp2 > tmp1
 sed "s/title_var/$tvar/g"                               tmp1 > tmp2
 sed "s/title_mjo/$MJO/g"                                tmp2 > tmp1
 sed "s/period/$PPP/g"                                   tmp1 > tmp2
 sed "s/vname/$MJO/g"                                    tmp2 > tmp1
 sed "s/model_use/$model/g"                              tmp1 > coh2.exec

grads -lbc << EOF
exec coh2.exec
EOF

 end 
# foreach var

