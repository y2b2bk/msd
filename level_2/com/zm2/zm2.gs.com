'reinit'

'open homedir/level_1/variable/data/daily.period.ctl'
'set x 1 num_x'
'set y 1'
'set z 1'
'set t 1 num_t'
 
'set fwrite homedir/level_1/variable/data/daily.10S10N.period.gdat'
'set gxout fwrite'
'd ave(p,lat=-10,lat=10)'
'disable fwrite'

'reinit'

'open homedir/level_1/variable/data/daily.anom.period.ctl'
'set x 1 num_x'
'set y 1'
'set z 1'
'set t 1 num_t'
 
'set fwrite homedir/level_1/variable/data/daily.anom.10S10N.period.gdat'
'set gxout fwrite'
'd ave(p,lat=-10,lat=10)'
'disable fwrite'
