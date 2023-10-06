'reinit'

'open homedir/level_1/variable/data/daily.filt.20-100.lanz.100.period.ctl'
'set x 1 num_x'
'set y 1'
'set z 1'
'set t 1 num_t'
 
'set fwrite homedir/level_1/variable/data/daily.filt.20-100.lanz.100.15S15N.period.gdat'
'set gxout fwrite'
'd ave(p,lat=-15,lat=15)'
'disable fwrite'

'reinit'

'open homedir/level_1/variable/data/daily.anom.period.ctl'
'set x 1 num_x'
'set y 1'
'set z 1'
'set t 1 num_t'
 
'set fwrite homedir/level_1/variable/data/daily.anom.15S15N.period.gdat'
'set gxout fwrite'
'd ave(p,lat=-15,lat=15)'
'disable fwrite'
