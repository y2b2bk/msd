'reinit'

'open homedir/level_1/variable/data/daily.filt.20-100.lanz.100.period.ctl'
'set x 1 num_x'
'set y 1'
'set z 1'
'set t 1 num_t'
 
'set fwrite homedir/level_1/variable/data/daily.filt.20-100.lanz.100.10S10N.period.gdat'
'set gxout fwrite'
'd ave(p,lat=-10,lat=10)'
'disable fwrite'

'reinit'

'open homedir/level_1/variable/data/daily.filt.20-100.lanz.100.period.ctl'
'set x 1'
'set y 1 num_y' 
'set z 1'
'set t 1 num_t'

'set fwrite homedir/level_1/variable/data/daily.filt.20-100.lanz.100.80E100E.period.gdat'
'set gxout fwrite'
'd ave(p,lon=80,lon=100)'
'disable fwrite'

'reinit'

'open homedir/level_1/variable/data/daily.filt.20-100.lanz.100.period.ctl'
'set x 1'
'set y 1 num_y' 
'set z 1'
'set t 1 num_t'

'set fwrite homedir/level_1/variable/data/daily.filt.20-100.lanz.100.115E135E.period.gdat'
'set gxout fwrite'
'd ave(p,lon=115,lon=135)'
'disable fwrite'
